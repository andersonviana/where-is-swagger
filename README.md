# 🔍 where-is-swagger

Script Bash para **descobrir automaticamente endpoints Swagger/OpenAPI** a partir de hosts informados (com ou sem protocolo), extraídos de serviços web, Ingress ou qualquer fonte Kubernetes.

## 📌 Funcionalidades

- ✅ Testa os principais caminhos padrão do Swagger/OpenAPI:
  - `/swagger-ui.html`
  - `/swagger-ui/`
  - `/swagger-ui/index.html`
  - `/v3/api-docs`
  - `/v2/api-docs`
  - `/docs`
  - `/openapi.json`
  - `/api-docs`
- ✅ Aceita **múltiplos hosts**, separados por vírgula
- ✅ Prioriza `https://` e **só tenta `http://` se `https://` falhar**
- ✅ Valida se `/v3/api-docs` ou `/openapi.json` retornam **JSON válido** (usa `jq`)
- ✅ Exibe resultados com códigos HTTP, destacando endpoints encontrados
- ✅ Ideal para uso com `kubectl` e Ingress no Kubernetes

---

## 📥 Requisitos

- `bash`
- `curl`

## 🚀 Como usar

### 1. Dê permissão de execução

```bash
chmod +x where-is-swagger.sh
```

### 2. Execute com hosts separados por vírgula

```bash
./where-is-swagger.sh api.servico.com,api2.servico.com
```

Você também pode informar URLs completas com `http://` ou `https://`:

```bash
./where-is-swagger.sh https://api.seguranca.com,http://api.legado.com
```

---

## 🧠 Uso com Kubernetes (Ingress)

Extraia os hosts de todos os Ingress de um namespace e use com o script:

```bash
HOSTS=$(kubectl get ingress -n meu-namespace -o jsonpath='{range .items[*]}{.spec.rules[0].host},{end}' | sed 's/,$//')
./where-is-swagger.sh "$HOSTS"
```

---

## 📤 Saída esperada

```text
🔍 Testando possíveis rotas do Swagger para: api.servico.com
🌐 Testando base: https://api.servico.com
✅ Encontrado: https://api.servico.com/v3/api-docs (HTTP 200)
🟢 JSON válido encontrado em: https://api.servico.com/v3/api-docs
-----------------------------------------------------
```
![image](https://github.com/user-attachments/assets/bf6e5cea-7d05-4943-b6d8-057c14cab3ba)


---

## 📝 Licença

Distribuído sob a licença [MIT](LICENSE). Sinta-se à vontade para usar, adaptar e contribuir com melhorias.

---

## 🤝 Contribuições

Pull requests são bem-vindos! Se encontrar novos padrões de endpoints Swagger ou melhorias, fique à vontade para enviar contribuições.
