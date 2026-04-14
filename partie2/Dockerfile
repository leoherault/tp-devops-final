# Étape 1 : Builder
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Étape 2 : Image finale
FROM node:18-alpine
WORKDIR /app
# On récupère les modules installés et TOUT le code source 

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app .

EXPOSE 3000
CMD ["npm", "start"]
