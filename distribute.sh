set -ev
docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
docker run -it --rm --privileged --name "${ADDON_NAME}" \
    -v ~/.docker:/root/.docker \
    -v "$(pwd)":/docker \
    hassioaddons/build-env:latest \
    --target "${ADDON_NAME}" \
    --git \
    --all \
    --push \
    --from "homeassistant/{arch}-base" \
    --author "Nicolai Bjerre Pedersen <mr.bjerre@gmail.com>" \
    --doc-url "${GITHUB_URL}"
