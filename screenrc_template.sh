#!/bin/bash
cat <<EOT
shelltitle ''
vbell on
autodetach on
startup_message off
defscrollback 2048
hardstatus alwayslastline "%-Lw%{= BW}%50>%n%f* %t%{-}%+Lw%< %=%D %M %d %c"
hardstatus string '%{= kK}%-Lw%{= KW}%50>%n%f %t%{= kK}%+Lw%< %{=kG}%-= %d%M %c:%s%{-}'
EOT
