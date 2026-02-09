FROM node:22
ARG DEBIAN_FRONTEND=noninteractive
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app

# Copy package files first for better layer caching
COPY --chown=node:node package.json .
COPY --chown=node:node .babelrc .

# Copy necessary directories to expected locations
# Note: legacy/app is copied to both locations because webpack.config.production.js requires:
#   - src/app/index.js (entry point via path.resolve)
#   - app/app.html (template via relative path)
COPY --chown=node:node legacy/app ./src/app
COPY --chown=node:node legacy/app ./app
COPY --chown=node:node legacy/background ./src/background
COPY --chown=node:node imports ./imports
COPY --chown=node:node translations ./translations

RUN npm install -g npm
USER node

RUN npm install --force
RUN ls -la
RUN npm run buildweb

EXPOSE 8095
CMD [ "node", "src/background/server.js" ]