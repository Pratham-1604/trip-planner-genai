FROM node:18 AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# ---- Production Stage ----
FROM node:18
WORKDIR /app
RUN npm install -g serve
COPY --from=build /app/build ./build

ENV PORT=8080
EXPOSE 8080
CMD ["serve", "-s", "build", "-l", "8080"]