# function to loop through a vector of packages and load each
# installs each package if not listed in installed packages directory.
install_pkgs <- function(packages)
{
    # directory of installed packages
    installed <- installed.packages()[, 'Package']
    
    # function to install
    install <- function(x) {
        # if package not in installed
        if (!(x %in% installed)) {
            # install then load
            install.packages(x)
            library(x, character.only=TRUE)
        } else {
            # else just load
            library(x, character.only=TRUE)
        }
    }
    
    # apply function to vector of packages
    sapply(packages, install)
}
