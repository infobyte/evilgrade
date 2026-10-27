package main

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/x509"
	"encoding/pem"
	"errors"
	"fmt"
	"math/big"
	"os"
)

func main() {
	pub, err := readP384FromCertificate(os.Args[1])
	if err != nil {
		panic(err)
	}

	for i := range 256 {
		x, y := elliptic.P384().ScalarBaseMult([]byte{byte(i)})
		if (pub.X.Cmp(x) == 0) && (pub.Y.Cmp(y) == 0) {

			key := &ecdsa.PrivateKey{
				D:         big.NewInt(int64(i)),
				PublicKey: *pub,
			}

			der, err := x509.MarshalECPrivateKey(key)
			if err != nil {
				panic(err)
			}

			pemData := pem.EncodeToMemory(&pem.Block{
				Type:  "EC PRIVATE KEY",
				Bytes: der,
			})

			if err := os.WriteFile(os.Args[1]+".key", pemData, 0600); err != nil {
				panic(err)
			}

		}
	}
}

func readP384FromCertificate(path string) (*ecdsa.PublicKey, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	block, _ := pem.Decode(data)
	if block == nil {
		return nil, errors.New("kein PEM-Block gefunden")
	}
	if block.Type != "CERTIFICATE" {
		return nil, fmt.Errorf(
			"erwartete CERTIFICATE, erhalten: %q",
			block.Type,
		)
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("Zertifikat parsen: %w", err)
	}

	pub, ok := cert.PublicKey.(*ecdsa.PublicKey)
	if !ok {
		return nil, fmt.Errorf(
			"kein ECDSA-Public-Key, sondern %T",
			cert.PublicKey,
		)
	}

	if pub.Curve != elliptic.P384() {
		return nil, fmt.Errorf(
			"erwartete P-384, erhalten: %s",
			pub.Curve.Params().Name,
		)
	}

	return pub, nil
}
