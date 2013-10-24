module XmlSnippets

  COMPLEX_UNMERGED = <<-EOF
   <w:r w:rsidR="00A64C49">
      <w:fldChar w:fldCharType="begin" />
    </w:r>
    <w:r w:rsidR="00A64C49">
      <w:instrText xml:space="preserve"> MERGEFIELD "First_Name" </w:instrText>
    </w:r>
    <w:r w:rsidR="00A64C49">
      <w:fldChar w:fldCharType="separate" />
    </w:r>
    <w:r w:rsidR="00202AFC">
      <w:rPr>
        <w:noProof />
      </w:rPr>
      <w:t>«First_</w:t>
    </w:r>
    <w:r w:rsidR="00202AFC" w:rsidRPr="00A64C49">
      <w:rPr>
        <w:b />
        <w:noProof />
      </w:rPr>
      <w:t>Nam</w:t>
    </w:r>
    <w:r w:rsidR="00202AFC">
      <w:rPr>
        <w:noProof />
      </w:rPr>
      <w:t>e»</w:t>
    </w:r>
    <w:r w:rsidR="00A64C49">
      <w:rPr>
        <w:noProof />
      </w:rPr>
      <w:fldChar w:fldCharType="end" />
    </w:r>
  EOF

  COMPLEX_MERGED = <<-EOF
    <w:r>
      <w:rPr>
        <w:noProof />
      </w:rPr>
      <w:t>Anna</w:t>
    </w:r>
  EOF

  SIMPLE_UNMERGED = <<-EOF
    <w:fldSimple w:instr=" MERGEFIELD &quot;First_Name&quot; ">
      <w:r w:rsidR="00202AFC">
        <w:rPr>
          <w:noProof/>
        </w:rPr>
        <w:t>«First_Name»</w:t>
      </w:r>
    </w:fldSimple>
  EOF

  SIMPLE_MERGED = <<-EOF
    <w:r w:rsidR="00202AFC">
        <w:rPr>
          <w:noProof/>
        </w:rPr>
        <w:t>Anna</w:t>
      </w:r>
  EOF
  def self.doc(body)
   doc = <<-EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" mc:Ignorable="w14 wp14">
      <w:body>
        #{body}
        <w:p w:rsidR="007B5CEC" w:rsidRDefault="0025648F">
          <w:bookmarkStart w:id="0" w:name="_GoBack" />
          <w:bookmarkEnd w:id="0" />
        </w:p>
        <w:sectPr w:rsidR="007B5CEC">
          <w:pgSz w:w="12240" w:h="15840" />
          <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />
          <w:cols w:space="720" />
          <w:docGrid w:linePitch="360" />
        </w:sectPr>
      </w:body>
    </w:document>
    EOF
end

end
