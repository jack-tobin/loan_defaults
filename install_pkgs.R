install.pkgs <- function(packages)
{
    installed <- installed.packages()[, 'Package']
    install <- function(x) {
        if (!(x %in% installed)) {
            install.packages(x)
            library(x, character.only=TRUE)
        } else {
            library(x, character.only=TRUE)
        }
    }
    sapply(packages, install)
}