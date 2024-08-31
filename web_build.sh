IN=src
OUT=web
rm -f "$OUT"/game.data
npx love.js -m 50331648 -t 'Space Attack!' "$IN" "$OUT"
cp favicon.ico "$OUT"

npm i --save coi-serviceworker
cp node_modules/coi-serviceworker/coi-serviceworker.js "$OUT"

sed -i '/<body>/a \    <script src="coi-serviceworker.js"></script>\n' "$OUT"/index.html
