FROM node:16.18

ENV PORT=3000

COPY . /frontend-react-js
WORKDIR /frontend-react-js
RUN npm install
EXPOSE ${PORT}
CMD ["npm", "start"]

#Multi-stage Build Steps

# FROM node:16.18 as base
# ENV PORT=3000
# COPY . /frontend-react-js
# WORKDIR /frontend-react-js
# RUN npm install

# FROM node:16.18.1-slim
# COPY --from=base /frontend-react-js/package-lock.json /frontend-react-js/
# WORKDIR /frontend-react-js
# EXPOSE ${PORT}
# CMD ["npm", "start"]
