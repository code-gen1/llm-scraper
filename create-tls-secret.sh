#!/bin/bash

# Script to create Kubernetes secret for Solace PubSub+ TLS certificate with password-protected private key
# This script creates a secret containing the certificate, private key, and passphrase file

set -e

# Configuration
SECRET_NAME="solace-tls-secret"
NAMESPACE="default"
CERT_DIR="/tmp/solace-tls"

echo "Creating Kubernetes secret for Solace PubSub+ TLS certificate..."

# Check if certificate files exist
if [[ ! -f "$CERT_DIR/server.crt" ]] || [[ ! -f "$CERT_DIR/server.key" ]] || [[ ! -f "$CERT_DIR/passphrase.txt" ]]; then
    echo "Error: Certificate files not found in $CERT_DIR"
    echo "Expected files: server.crt, server.key, passphrase.txt"
    exit 1
fi

# Delete existing secret if it exists (ignore errors)
kubectl delete secret "$SECRET_NAME" -n "$NAMESPACE" 2>/dev/null || true

# Create the secret with certificate, key, and passphrase
kubectl create secret generic "$SECRET_NAME" \
    --from-file=tls.crt="$CERT_DIR/server.crt" \
    --from-file=tls.key="$CERT_DIR/server.key" \
    --from-file=passphrase.txt="$CERT_DIR/passphrase.txt" \
    --namespace="$NAMESPACE"

echo "Secret '$SECRET_NAME' created successfully in namespace '$NAMESPACE'"

# Verify the secret was created
echo "Verifying secret contents:"
kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" -o yaml | grep -E "^  (tls\.crt|tls\.key|passphrase\.txt):" || true

echo "TLS secret creation completed!"
