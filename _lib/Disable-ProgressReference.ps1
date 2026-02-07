# https://www.techpowerup.com/download/visual-c-redistributable-runtime-package-all-in-one/

$default = $ProgressPreference

function Disable-ProgressReference {
  $ProgressPreference = 'SilentlyContinue'
}

function Restore-ProgressReference {
    $ProgressPreference = $default
}
