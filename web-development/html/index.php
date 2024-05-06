<!DOCTYPE html>
<html>
    <head>
            <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
    <link rel="stylesheet" type="text/css" href="style.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" href="https://unpkg.com/swiper/swiper-bundle.min.css"/>
        <title>Notre première instruction : echo</title>
        <meta charset="utf-8" />
    </head>
    <body>

    <section>
      <div class="text-center">
        <h1>Tools</h1>
      </div>
            <div class="swiper mySwiper">
                <div class="swiper-wrapper">
                  <div class="swiper-slide">
          
                    <div class="text-center">
                        <h2>Chiffrement</h2>
                        <?php if (empty($_FILES['fileToUpload_Encrypt']['tmp_name'])) { ?>
            <form action="index.php" method="POST" enctype="multipart/form-data">
                <input type="file" name="fileToUpload_Encrypt">
                <input type="submit" value="Upload File">
                <input type="hidden" name="filename" id="filename">
            </form>

        <?php } else { ?>
            <form action="index.php" method="POST" enctype="multipart/form-data">
                <input type="file" name="fileToUpload_Encrypt">
                <input type="submit" value="Upload File">
                <input type="hidden" name="filename" id="filename">
            </form>



            <?php
                // Lorsque le fichier est uploadé, le mettre dans un dossier temporaire et unique, mais conserver le nom de fichier original. tester move_uploaded_file() à la place de file_get_contents
                $newfilename = $_FILES['fileToUpload_Encrypt']['name'];       // Conserve juste le nom du fichier sans le path.
                $permanentFilePath = '/var/www/html/upload/' . $newfilename;  // Chemin de sauvegarde du fichier
                move_uploaded_file($_FILES['fileToUpload_Encrypt']['tmp_name'], $permanentFilePath);
                $fileContentt_modif = escapeshellcmd('python3 test.py \'' . $permanentFilePath . '\' IdCardEncrypt');
                shell_exec($fileContentt_modif);
                var_dump(file_get_contents($permanentFilePath));
        }
         ?>
        </br>
        <a class="btn btn-primary" href="upload/<?= $newfilename ?>" download>Download Encrypted File</a>
                            
                    </div>
                 </div>
                
            <div class="swiper-slide">
                <div class="text-center">
                    <h2>Déchiffrement</h2>
                        <div class="row">
                            <div class="col-md-12">
                                <div class="main-timeline9">
                                <?php if (empty($_FILES['fileToUpload_Decrypt']['tmp_name'])) { ?>
             <form action="index.php" method="POST" enctype="multipart/form-data">
                 <input type="file" name="fileToUpload_Decrypt">
                 <input type="submit" value="Upload File">
                 <input type="hidden" name="filename" id="filename">
             </form>
        

         <?php } else { ?>
             <form action="index.php" method="POST" enctype="multipart/form-data">
                 <input type="file" name="fileToUpload_Decrypt">
                 <input type="submit" value="Upload File">
                 <input type="hidden" name="filename" id="filename">
             </form>
        
 
        
             <?php
                 $newfilename = $_FILES['fileToUpload_Decrypt']['name'];
                 $permanentFilePath = '/var/www/html/upload/' . $newfilename;
                 move_uploaded_file($_FILES['fileToUpload_Decrypt']['tmp_name'], $permanentFilePath);
                 $fileContentt_modif = escapeshellcmd('python3 test.py \'' . $permanentFilePath . '\' IdCardDecrypt');
                 shell_exec($fileContentt_modif);
                 var_dump(file_get_contents($permanentFilePath));      
         }
          ?>
         </br>
         <a class="btn btn-primary"href="upload/<?= $newfilename ?>" download>Download Decrypted File</a>                      
                                </div>
                            </div>
                        </div>
                </div>
                  </br></br></br>
                  </div>
                
                  
                </div>
                <div class="swiper-button-next"></div>
                <div class="swiper-button-prev"></div>
                <div class="swiper-pagination"></div>
            </div>
          
              <!-- Swiper JS -->
              <script src="https://unpkg.com/swiper/swiper-bundle.min.js"></script>
          
              <!-- Initialize Swiper -->
              <script>
                var swiper = new Swiper(".mySwiper", {
                  slidesPerView: 1,
                  spaceBetween: 30,
                  keyboard: {
                    enabled: true,
                  },
                  pagination: {
                    el: ".swiper-pagination",
                    clickable: true,
                  },
                  navigation: {
                    nextEl: ".swiper-button-next",
                    prevEl: ".swiper-button-prev",
                  },
                });
              </script>
    </section>


    </body>
</html>
