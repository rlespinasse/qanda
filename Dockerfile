FROM alpine
RUN apk add bash fzf

WORKDIR /app
ENV FZF_DEFAULT_OPTS "--layout=reverse --inline-info --tabstop=2"
COPY qanda.sh samples/how_to_use_it.puml /app/

WORKDIR /data
VOLUME /data
ENTRYPOINT ["/app/qanda.sh"]
CMD ["/app/how_to_use_it.puml"]
