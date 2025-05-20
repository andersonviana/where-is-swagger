#!/usr/bin/env bash

# Verifica se foi passado pelo menos um host valido
if [[ -z "$1" ]]; then
  echo "❌ Uso: ./where-is-swagger.sh host1.com[,host2.com,...]"
  exit 1
fi

# Caminhos Swagger conhecidos
SWAGGER_PATHS=(
  "swagger-ui.html"
  "swagger-ui/"
  "swagger-ui/index.html"
  "v3/api-docs"
  "v2/api-docs"
  "docs"
  "openapi.json"
  "api-docs"
)

# Separa os hosts por vírgula
IFS=',' read -ra HOSTS <<< "$1"

# Loop pelos hosts
for RAW_BASE in "${HOSTS[@]}"; do
  RAW_BASE="${RAW_BASE// /}"  # remove espaços
  echo "🔍 Testando possíveis rotas do Swagger para: $RAW_BASE"

  HTTPS_SUCCESS=false

  # Primeiro testa com HTTPS
  BASE_URL="https://${RAW_BASE%/}"
  echo "🌐 Testando base: $BASE_URL"
  for path in "${SWAGGER_PATHS[@]}"; do
    FULL_URL="${BASE_URL}/${path}"
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$FULL_URL")

    if [[ "$STATUS" == "200" || "$STATUS" == "301" || "$STATUS" == "302" ]]; then
      echo "✅ Encontrado: $FULL_URL (HTTP $STATUS)"
      HTTPS_SUCCESS=true
    else
      echo "❌ Não encontrado: $FULL_URL (HTTP $STATUS)"
    fi
  done

  if [[ "$HTTPS_SUCCESS" == false ]]; then
    BASE_URL="http://${RAW_BASE%/}"
    echo "🌐 Testando base alternativa: $BASE_URL"
    for path in "${SWAGGER_PATHS[@]}"; do
      FULL_URL="${BASE_URL}/${path}"
      STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$FULL_URL")

      if [[ "$STATUS" == "200" || "$STATUS" == "301" || "$STATUS" == "302" ]]; then
        echo "✅ Encontrado: $FULL_URL (HTTP $STATUS)"
      else
        echo "❌ Não encontrado: $FULL_URL (HTTP $STATUS)"
      fi
    done
  fi

  # Teste extra: verificar se /v3/api-docs e /openapi.json retornam JSON válido
  for json_path in "v3/api-docs" "openapi.json"; do
    JSON_URL="${BASE_URL}/${json_path}"
    RESPONSE=$(curl -s "$JSON_URL")

    if [[ -n "$RESPONSE" ]]; then
      echo "$RESPONSE" | jq empty 2>/dev/null
      if [[ $? -eq 0 ]]; then
        echo "🟢 JSON válido encontrado em: $JSON_URL"
      else
        echo "⚠️  Resposta em $JSON_URL não é JSON válido"
      fi
    fi
  done

  echo "-----------------------------------------------------"
done

echo "📝 Teste concluído."