function addDropDown(){

  if (fileFieldCount >= 10) return false
  fileFieldCount++;
  var f = document.createElement("input");
  f.type = "file";
  f.name = "attachments[" + fileFieldCount + "][file]";
  f.size = 30;
  var d = document.createElement("input");
  d.type = "text";
  d.name = "attachments[" + fileFieldCount + "][description]";
  d.size = 60;
  
  p = document.getElementById("attachments_fields");
  p.appendChild(document.createElement("br"));
  p.appendChild(f);
  p.appendChild(d);

} 
