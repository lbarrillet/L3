import sys

if len(sys.argv) > 1:
  filePath = sys.argv[1]
  with open(filePath, 'r') as file:
    content = file.read()
    modifiedContent = content.upper() # Modifier le contenu ici
    print(modifiedContent)
