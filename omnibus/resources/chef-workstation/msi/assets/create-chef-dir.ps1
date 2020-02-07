$chef_path = "$HOME\.chef"

If(!(test-path $chef_path))
{
  New-Item -ItemType Directory -Force -Path $chef_path
}