FROM akxcv/infometer
LABEL name "infometer"

WORKDIR /home/infometer
COPY server ./temp/server
COPY client/dist ./client

RUN (eval `opam config env` && cd temp/server && make && cp ./_build/src/main.native ../..)
RUN rm -r temp

EXPOSE 3000

ENTRYPOINT ["./main.native"]
