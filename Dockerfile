FROM golang:1.25-alpine3.19 AS build_deps

RUN apk add --no-cache git

WORKDIR /workspace

COPY go.mod .
COPY go.sum .

RUN go mod download

FROM build_deps AS build

COPY . .

RUN CGO_ENABLED=0 go build -o webhook -ldflags '-w -extldflags "-static"' .

FROM alpine:3.18

RUN apk add --no-cache ca-certificates && \
    addgroup -g 1000 appgroup && \
    adduser -D -u 1000 -G appgroup appuser

COPY --from=build --chown=appuser:appgroup /workspace/webhook /usr/local/bin/webhook

USER appuser

ENTRYPOINT ["webhook"]
