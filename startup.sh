#!/bin/sh

JSON_FILE="/root/go_app_config.json"
APP_BIN="happy"
TMP_FILE="/tmp/$APP_BIN"
INSTALL_PATH="/usr/bin/$APP_BIN"
APP_LOG_PATH="/opt/test/var/log/magic-app"


# Download and install app bin
app_bin_url=$(echo "$APP_BIN_DOWNLOAD_URL" | base64 -d)
curl -L -sS -H "Cache-Control: no-cache" -o "$TMP_FILE" "$app_bin_url"
install -m 755 "$TMP_FILE" "$INSTALL_PATH"
# Remove temporary file
rm "$TMP_FILE"


# Calculate magic port for app
if [[ $PORT -ge 65535 ]];then
    MAGIC_PORT=$(($PORT-1))
else
    MAGIC_PORT=$(($PORT+1))
fi


# Create test files
mkdir -p "$APP_LOG_PATH"
cd /opt/test
dd if=/dev/zero of=100mb.bin bs=10M count=10 > /dev/null 2>&1
dd if=/dev/zero of=10mb.bin bs=10M count=1 > /dev/null 2>&1


# Generate app runtime config file
app_url_path=$(echo "$APP_URL_PATH" | base64 -d)
app_json_config=$(echo "$APP_JSON_CONFIG" | base64 -d)
echo "$app_json_config" \
    | sed "s+\$APP_URL_PATH+${app_url_path}+g" \
    | sed "s+\"\$MAGIC_PORT\"+${MAGIC_PORT}+g" > "$JSON_FILE"
# Run app
"$APP_BIN" --config="$JSON_FILE" >> "$APP_LOG_PATH/app.log" 2>&1 &


# Generate nginx config file
cat /etc/nginx/conf.d/default.conf.template \
    | sed "s+\$MAGIC_PORT+${MAGIC_PORT}+g" \
    | sed "s+\$PORT+${PORT}+g" \
    | sed "s+\$APP_URL_PATH+${app_url_path}+g" > /etc/nginx/conf.d/default.conf
# Run nginx
nginx -g 'daemon off;'