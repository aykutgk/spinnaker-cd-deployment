FROM node:12.16.3-alpine

WORKDIR /app

ADD package.json /tmp
ADD yarn.lock /tmp

ADD build/ /tmp/build

RUN cd /tmp && yarn

RUN cp -r /tmp/node_modules /app/node_modules

ADD . .

EXPOSE 8080

CMD [ "yarn", "start" ]