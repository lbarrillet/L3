<?php
  
  
  $fileContentt = file_get_contents($_FILES['fileToUpload_Encrypt']['tmp_name']);
  print("A\n");
  var_dump($fileContentt);
  $fileContentt_modif = escapeshellcmd('python3 test.py ' . $_FILES['fileToUpload_Encrypt']['tmp_name'] . ' IdCardEncrypt');
  print("B\n");
  var_dump($fileContentt_modif);
  $output = shell_exec($fileContentt_modif);
  print("C\n");
  var_dump(file_get_contents($_FILES['fileToUpload_Encrypt']['tmp_name']));
?>

