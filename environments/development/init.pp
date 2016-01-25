# Set up default exec path
Exec { path => "/bin:/usr/bin" }


hiera_include(classes)

node default {
}
