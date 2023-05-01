TEMPLATES_DIR=~/Library/Developer/Xcode/Templates/File\ Templates/Numan
rm -r "$TEMPLATES_DIR"
mkdir -p "$TEMPLATES_DIR"
cp -R *.xctemplate "$TEMPLATES_DIR"
echo "Templates updated. Now restart Xcode!"