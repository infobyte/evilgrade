
if [ $# -ne 1 ]
then
echo "$0 [host_name]"
exit 0
fi
HOST="$1"

openssl genrsa -out key.pem 1024
openssl rsa -noout -text -in key.pem
openssl req -new -key key.pem -out req.pem
openssl req -x509 -key key.pem -in req.pem -out cert.pem -days 365

mv cert.pem "$HOST-cert.pem"
mv key.pem "$HOST-key.pem"

