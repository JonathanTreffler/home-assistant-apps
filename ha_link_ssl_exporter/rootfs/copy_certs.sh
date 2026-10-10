#!/usr/bin/with-contenv bashio

files_updated=false

auto_restart_apps=$(bashio::config 'auto_restart_apps')

copy_if_newer() {
    local source="$1"
    local dest="$2"

    if [[ ! -e "$source" ]]; then
        echo "Skipped (source file not found) $source"
        return 0
    fi

    if [[ ! -e "$dest" || "$source" -nt "$dest" ]]; then
        if cp "$source" "$dest"; then
            touch -r "$source" "$dest" 2>/dev/null || true
            echo "Updated file $dest"
            files_updated=true
            return 0
        else
            echo "Error copying $source to $dest" >&2
            return 1
        fi
    else
        echo "Skipped (already up to date) $dest"
        return 0
    fi
}

copy_if_newer /homeassistant_config/.cloud/remote_fullchain.pem /ssl/remote_fullchain.pem
copy_if_newer /homeassistant_config/.cloud/remote_private.pem /ssl/remote_private.pem

if [[ "$files_updated" == true ]]; then
    echo -n "Files updated, "
    if [[ -n "$auto_restart_apps" ]]; then
     echo "restarting apps..."
      while read -r app; do
          if bashio::app.restart "$app"; then
              echo "Successfully restarted $app"
          else
              echo "Failed restarting $app"
          fi
       done <<< "$auto_restart_apps"
    fi
    echo "exiting"
else
    echo "No files updated, exiting"
fi
