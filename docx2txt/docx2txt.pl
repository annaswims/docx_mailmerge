#!/usr/bin/env perl

# docx2txt, a command-line utility to convert Docx documents to text format.
# Copyright (C) 2008-2012 Sandeep Kumar
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

#
# This script extracts text from document.xml contained inside .docx file.
# Perl v5.10.1 was used for testing this script.
#
# Author : Sandeep Kumar (shimple0 -AT- Yahoo .DOT. COM)
#
# ChangeLog :
#
#    10/08/2008 - Initial version (v0.1)
#    15/08/2008 - Script takes two arguments [second optional] now and can be
#                 used independently to extract text from docx file. It accepts
#                 docx file directly, instead of xml file.
#    18/08/2008 - Added support for center and right justification of text that
#                 fits in a line 80 characters wide (adjustable).
#    03/09/2008 - Fixed the slip in usage message.
#    12/09/2008 - Slightly changed the script invocation and argument handling
#                 to incorporate some of the shell script functionality here.
#                 Added support to handle embedded urls in docx document.
#    23/09/2008 - Changed #! line to use /usr/bin/env - good suggestion from
#                 Rene Maroufi (info>AT<maroufi>DOT<net) to reduce user work
#                 during installation.
#    31/08/2009 - Added support for handling more escape characters.
#                 Using OS specific null device to redirect stderr.
#                 Saving text file in binary mode.
#    03/09/2009 - Updations based on feedback/suggestions from Sergei Kulakov
#                 (sergei>AT<dewia>DOT<com).
#                 - removal of non-document text in between TOC related tags.
#                 - display of hyperlink alongside linked text user controlled.
#                 - some character conversion updates
#    05/09/2009 - Merged cjustify and rjustify into single subroutine justify.
#                 Added more character conversions.
#                 Organised conversion mappings in tabular form for speedup and
#                 easy maintenance.
#                 Tweaked code to reduce number of passes over document content.
#    10/09/2009 - For leaner text experience, hyperlink is not displayed if
#                 hyperlink and hyperlinked text are same, even if user has
#                 enabled hyperlink display.
#                 Improved handling of short line justification. Many
#                 justification tag patterns were not captured earlier.
#    11/09/2009 - A directory holding the unzipped content of .docx file can
#                 also be specified as argument to the script, in place of file.
#    17/09/2009 - Removed trailing slashes from input directory name.
#                 Updated unzip command invocations to handle path names
#                 containing spaces.
#    01/10/2009 - Added support for configuration file.
#    02/10/2009 - Using single quotes to specify path for unzip command. 
#    04/10/2009 - Corrected configuration option name lineIndent to listIndent.
#    11/12/2011 - Configuration variables now begin with config_ .
#                 Configuration file is looked for in HOME directory as well.
#                 Added a check for existence of unzip command.
#                 Superscripted cross-references are placed within [...] now.
#                 Fixed bugs #3003903, #3082018 and #3082035.
#                 Fixed nullDevice for Cygwin.
#    12/12/2011 - Configuration file is also looked for in /etc, default
#                 location for Unix-ish systems.
#    22/12/2011 - Added &apos; and &quot; to docx specific escape characters
#                 conversions. [Bug #3463033]
#    24/12/2011 - Improved handling of special (non-text) characters, along with
#                 support for more non-text characters.
#    05/01/2012 - Configuration file is now looked for in current directory,
#                 user configuration directory and system configuration
#                 directory (in the specified order). This streamlining allows
#                 for per user configuration file even on Windows.
#    14/01/2012 - Wrong code was committed during earlier fixing of nullDevice
#                 for Cygwin, fixed that.
#                 Usage is extended to accept docx file from standard input.
#                 "-h" has to be given as the first argument to get usage help.
#                 Added new configuration variable "config_tempDir".
#


#
# The default settings below can be overridden via docx2txt.config in current
# directory/ user configuration directory/ system configuration directory.
#

our $config_unzip = '/usr/bin/unzip';	# Windows path like 'C:/path/to/unzip.exe'

our $config_newLine = "\n";		# Alternative is "\r\n".
our $config_listIndent = "  ";		# Indent nested lists by "\t", " " etc.
our $config_lineWidth = 80;		# Line width, used for short line justification.
our $config_showHyperLink = "N";	# Show hyperlink alongside linked text.
our $config_tempDir;			# Directory for temporary file creation.


#
# Some experimental settings.
#

our $config_exp_extra_deEscape = "N";   # Extra conversion of &...; sequences.


#
# Windows/Non-Windows specific settings. Adjust these here, if needed.
#

if ($ENV{OS} =~ /^Windows/ && !(exists $ENV{OSTYPE} || exists $ENV{HOME})) {
    $nullDevice = "nul";
    $userConfigDir = $ENV{APPDATA};

    #
    # On Windows, configuration file is installed in same folder as this script.
    #
    $0 =~ m%^(.*[/\\])[^/\\]*?$%;
    $systemConfigDir = $1;

    $config_tempDir = "$ENV{TEMP}";
} else {
    $nullDevice = "/dev/null";
    $userConfigDir = $ENV{HOME};
    $systemConfigDir = "/etc";

    $config_tempDir = "/tmp";
}


#
# ToDo: Better list handling. Currently assumed 8 level nesting.
#
my @levchar = ('*', '+', 'o', '-', '**', '++', 'oo', '--');


#
# Character conversion tables
#

# Only (amp, apos, gt, lt and quot) are the required reserved characters in HTML
# and XHTML, others are used for better text experience.
my %escChrs = (	amp => '&', apos => '\'', gt => '>', lt => '<', quot => '"',
		acute => '\'', brvbar => '|', copy => '(C)', divide => '/',
		laquo => '<<', macr => '-', nbsp => ' ', raquo => '>>',
		reg => '(R)', shy => '-', times => 'x'
);

my %splchars = (
    "\xC2" => {
	"\xA0" => ' ',		# <nbsp> non-breaking space
	"\xA2" => 'cent',	# <cent>
	"\xA3" => 'Pound',	# <pound>
	"\xA5" => 'Yen',	# <yen>
	"\xA6" => '|',		# <brvbar> broken vertical bar
#	"\xA7" => '',		# <sect> section
	"\xA9" => '(C)',	# <copy> copyright
	"\xAB" => '<<',		# <laquo> angle quotation mark (left)
	"\xAC" => '-',		# <not> negation
	"\xAE" => '(R)',	# <reg> registered trademark
	"\xB1" => '+-',		# <plusmn> plus-or-minus
	"\xB4" => '\'',		# <acute>
	"\xB5" => 'u',		# <micro>
#	"\xB6" => '',		# <para> paragraph
	"\xBB" => '>>',		# <raquo> angle quotation mark (right)
	"\xBC" => '(1/4)',	# <frac14> fraction 1/4
	"\xBD" => '(1/2)',	# <frac12> fraction 1/2
	"\xBE" => '(3/4)',	# <frac34> fraction 3/4
    },

    "\xC3" => {
	"\x97" => 'x',		# <times> multiplication
	"\xB7" => '/',		# <divide> division
    },

    "\xCF" => {
	"\x80" => 'PI',		# <pi>
    },

    "\xE2\x80" => {
	"\x82" => '  ',		# <ensp> en space
	"\x83" => '  ',		# <emsp> em space
	"\x85" => ' ',		# <qemsp>
	"\x93" => ' - ',	# <ndash> en dash
	"\x94" => ' -- ',	# <mdash> em dash
	"\x95" => '--',		# <horizontal bar>
	"\x98" => '`',		# <soq>
	"\x99" => '\'',		# <scq>
	"\x9C" => '"',		# <doq>
	"\x9D" => '"',		# <dcq>
	"\xA2" => '::',		# <diamond symbol>
	"\xA6" => '...',	# <hellip> horizontal ellipsis
	"\xB0" => '%.',		# <permil> per mille
    },

    "\xE2\x82" => {
	"\xAC" => 'Euro'	# <euro>
    },

    "\xE2\x84" => {
	"\x85" => 'c/o',	# <care/of>
	"\x97" => '(P)',	# <sound recording copyright>
	"\xA0" => '(SM)',	# <servicemark>
	"\xA2" => '(TM)',	# <trade> trademark
	"\xA6" => 'Ohm',	# <Ohm>
    },

    "\xE2\x85" => {
	"\x93" => '(1/3)',
	"\x94" => '(2/3)',
	"\x95" => '(1/5)',
	"\x96" => '(2/5)',
	"\x97" => '(3/5)',
	"\x98" => '(4/5)',
	"\x99" => '(1/6)',
	"\x9B" => '(1/8)',
	"\x9C" => '(3/8)',
	"\x9D" => '(5/8)',
	"\x9E" => '(7/8)',
	"\x9F" => '1/',
    },

    "\xE2\x86" => {
	"\x90" => '<--',	# <larr> left arrow
	"\x92" => '-->',	# <rarr> right arrow
	"\x94" => '<-->',	# <harr> left right arrow
    },

    "\xE2\x88" => {
	"\x82" => 'd',		# partial differential
	"\x9E" => 'infinity',
    },

    "\xE2\x89" => {
	"\xA0" => '!=',		# <neq>
	"\xA4" => '<=',		# <leq>
	"\xA5" => '>=',		# <geq>
    }
);


#
# Check argument(s) sanity.
#

my $usage = <<USAGE;

Usage:	$0 [infile.docx|-|-h] [outfile.txt|-]
	$0 < infile.docx
	$0 < infile.docx > outfile.txt

	In second usage, output is dumped on STDOUT.

	Use '-h' as the first argument to get this usage information.

	Use '-' as the infile name to read the docx file from STDIN.

	Use '-' as the outfile name to dump the text on STDOUT.
	Output is saved in infile.txt if second argument is omitted.

Note:	infile.docx can also be a directory name holding the unzipped content
	of concerned .docx file.

USAGE

die $usage if (@ARGV > 2 || $ARGV[0] eq '-h');


#
# Look for configuration file in current directory/ user configuration
# directory/ system configuration directory - in the given order.
#

my %config;

if (-f "docx2txt.config") {
    %config = do 'docx2txt.config';
} elsif (-f "$userConfigDir/docx2txt.config") {
    %config = do "$userConfigDir/docx2txt.config";
} elsif (-f "$systemConfigDir/docx2txt.config") {
    %config = do "$systemConfigDir/docx2txt.config";
}

if (%config) {
    foreach my $var (keys %config) {
        $$var = $config{$var};
    }
}

#
# Check for unzip utility, before proceeding further.
#

die "Failed to locate unzip command '$config_unzip'!\n" if ! -f $config_unzip;


#
# Handle cases where this script reads docx file from STDIN.
#

if (@ARGV == 0) {
    $ARGV[0] = '-';
    $ARGV[1] = '-';
    $inputFileName = "STDIN";
} elsif (@ARGV == 1 && $ARGV[0] eq '-') {
    $ARGV[1] = '-';
    $inputFileName = "STDIN";
} else {
    $inputFileName = $ARGV[0];
}

if ($ARGV[0] eq '-') {
    $tempFile = "${config_tempDir}/dx2tTemp_${$}_" . time() . ".docx";
    open my $fhTemp, "> $tempFile" or die "Can't create temporary file for storing docx file read from STDIN!\n";

    binmode $fhTemp;
    local $/ = undef;
    my $docxFileContent = <STDIN>;

    print $fhTemp $docxFileContent;
    close $fhTemp;

    $ARGV[0] = $tempFile;
}


#
# Check for existence and readability of required file in specified directory,
# and whether it is a text file.
#

sub check_for_required_file_in_folder {
    stat("$_[1]/$_[0]");
    die "Can't read <$_[0]> in <$_[1]>!\n" if ! (-f _ && -r _);
    die "<$_[1]/$_[0]> does not seem to be a text file!\n" if ! -T _;
}

sub readFileInto {
    local $/ = undef;
    open my $fh, "$_[0]" or die "Couldn't read file <$_[0]>!\n";
    binmode $fh;
    $_[1] = <$fh>;
    close $fh;
}


#
# Check whether first argument is specifying a directory holding extracted
# content of .docx file, or .docx file itself.
#

sub cleandie {
    unlink("$tempFile") if -e "$tempFile";
    die "$_[0]";
}
    

stat($ARGV[0]);

if (-d _) {
    check_for_required_file_in_folder("word/document.xml", $ARGV[0]);
    check_for_required_file_in_folder("word/_rels/document.xml.rels", $ARGV[0]);
    $inpIsDir = 'y';
}
else {
    cleandie "Can't read docx file <$inputFileName>!\n" if ! (-f _ && -r _);
    cleandie "<$inputFileName> does not seem to be a docx file!\n" if -T _;
}


#
# Extract xml document content from argument docx file/directory.
#

if ($inpIsDir eq 'y') {
    readFileInto("$ARGV[0]/word/document.xml", $content);
} else {
    $content = `"$config_unzip" -p "$ARGV[0]" word/document.xml 2>$nullDevice`;
}

cleandie "Failed to extract required information from <$inputFileName>!\n" if ! $content;


#
# Be ready for outputting the extracted text contents.
#

if (@ARGV == 1) {
     $ARGV[1] = $ARGV[0];

     # Remove any trailing slashes to generate proper output filename, when
     # input is directory.
     $ARGV[1] =~ s%[/\\]+$%% if ($inpIsDir eq 'y');

     $ARGV[1] .= ".txt" if !($ARGV[1] =~ s/\.docx$/\.txt/);
}

my $txtfile;
open($txtfile, "> $ARGV[1]") || cleandie "Can't create <$ARGV[1]> for output!\n";
binmode $txtfile;    # Ensure no auto-conversion of '\n' to '\r\n' on Windows.


#
# Gather information about header, footer, hyperlinks, images, footnotes etc.
#

if ($inpIsDir eq 'y') {
    readFileInto("$ARGV[0]/word/_rels/document.xml.rels", $_);
} else {
    $_ = `"$config_unzip" -p "$ARGV[0]" word/_rels/document.xml.rels 2>$nullDevice`;
}

my %docurels;
while (/<Relationship Id="(.*?)" Type=".*?\/([^\/]*?)" Target="(.*?)"( .*?)?\/>/g)
{
    $docurels{"$2:$1"} = $3;
}

# Remove the temporary file (if) created to store input from STDIN. All the
# (needed) data is read from it already.
unlink("$tempFile") if -e "$tempFile";


#
# Subroutines for center and right justification of text in a line.
#

sub justify {
    my $len = length $_[1];

    if ($_[0] eq "center" && $len < ($config_lineWidth - 1)) {
        return ' ' x (($config_lineWidth - $len) / 2) . $_[1];
    } elsif ($_[0] eq "right" && $len < $config_lineWidth) {
        return ' ' x ($config_lineWidth - $len) . $_[1];
    } else {
        return $_[1];
    }
}

#
# Subroutines for dealing with embedded links and images
#

sub hyperlink {
    my $hlrid = $_[0];
    my $hltext = $_[1];
    my $hlink = $docurels{"hyperlink:$hlrid"};

    $hltext =~ s/<[^>]*?>//og;
    $hltext .= " [HYPERLINK: $hlink]" if (lc $config_showHyperLink eq "y" && $hltext ne $hlink);

    return $hltext;
}

#
# Subroutines for processing paragraph content.
#

sub processParagraph {
    my $para = $_[0] . "$config_newLine";
    my $align = $1 if ($_[0] =~ /<w:jc w:val="([^"]*?)"\/>/);

    $para =~ s/<.*?>//og;
    return justify($align,$para) if $align;

    return $para;
}

#
# Text extraction starts.
#

my %tag2chr = (tab => "\t", noBreakHyphen => "-", softHyphen => " - ");

$content =~ s/<?xml .*?\?>(\r)?\n//;

# Remove the field instructions (instrText) and data (fldData).
$content =~ s|<w:instrText[^>]*>.*?</w:instrText>||og;
$content =~ s|<w:fldData[^>]*>[^<]*?</w:fldData>||og;

# Mark cross-reference superscripting within [...].
$content =~ s|<w:vertAlign w:val="superscript"/></w:rPr><w:t>(.*?)</w:t>|[$1]|og;

$content =~ s{<w:(tab|noBreakHyphen|softHyphen)/>}|$tag2chr{$1}|og;

my $hr = '-' x $config_lineWidth . $config_newLine;
$content =~ s|<w:pBdr>.*?</w:pBdr>|$hr|og;

$content =~ s|<w:numPr><w:ilvl w:val="([0-9]+)"/>|$config_listIndent x $1 . "$levchar[$1] "|oge;

#
# Uncomment either of below two lines and comment above line, if dealing
# with more than 8 level nested lists.
#

# $content =~ s|<w:numPr><w:ilvl w:val="([0-9]+)"/>|$config_listIndent x $1 . '* '|oge;
# $content =~ s|<w:numPr><w:ilvl w:val="([0-9]+)"/>|'*' x ($1+1) . ' '|oge;

$content =~ s{<w:caps/>.*?(<w:t>|<w:t [^>]+>)(.*?)</w:t>}/uc $2/oge;

$content =~ s{<w:hyperlink r:id="(.*?)".*?>(.*?)</w:hyperlink>}/hyperlink($1,$2)/oge;

$content =~ s/<w:p[^>]+?>(.*?)<\/w:p>/processParagraph($1)/oge;

$content =~ s{<w:p [^/>]+?/>|</w:p>|<w:br/>}|$config_newLine|og;
$content =~ s/<.*?>//og;


#
# Convert non-ASCII characters/character sequences to ASCII characters.
#

$content =~ s/(\xC2|\xC3|\xCF|\xE2.)(.)/($splchars{$1}{$2} ? $splchars{$1}{$2} : $1.$2)/oge;

#
# Convert docx specific (reserved HTML/XHTML) escape characters.
#
$content =~ s/(&)(amp|apos|gt|lt|quot)(;)/$escChrs{lc $2}/iog;

#
# Another pass for experimental text experience, after sequences like
# "&amp;laquo;" are converted to "&laquo;".
#
$content =~ s/((&)([a-z]+)(;))/($escChrs{lc $3} ? $escChrs{lc $3} : $1)/ioge if (lc $config_exp_extra_deEscape eq "y");

#
# Write the extracted and converted text contents to output.
#

print $txtfile $content;
close $txtfile;

