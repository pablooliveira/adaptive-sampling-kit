#!/usr/bin/env Rscript
# Copyright (c) 2011-2012, Universite de Versailles St-Quentin-en-Yvelines
#
# This file is part of ASK.  ASK is free software: you can redistribute
# it and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation, version 2.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51
# Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


args <- commandArgs(trailingOnly = T)

if (length(args) != 6) {
    stop("Usage: 2D.R <configuration> <test_set> <predicted> <labelled> <newly_labelled> <output.png>")
}

source(file.path(Sys.getenv("ASKHOME"), "common/configuration.R"))
testset = read.table(args[2])
predicted = read.table(args[3])
labelled = read.table(args[4])
newlylabelled = read.table(args[5])
outputpng = args[6]

D = data.frame(X=testset$V1,Y=testset$V2,
               E=abs(testset$V3-predicted$V3),
               P=predicted$V3)

suppressPackageStartupMessages(require(graphics, quietly=T))
suppressPackageStartupMessages(require(lattice, quietly=T))
png(file=outputpng, width=1000, height=1200)

ep = levelplot(D$E ~ D$X*D$Y, cuts=31,
        colorkey=list(col=rev(heat.colors(32))),
        col.regions=rev(heat.colors(32)),
        at=seq(from=0,to=conf("modules.reporter.params.max_error_scale",
                              max(D$E))
          ,length=32),
        xlab="X",
        ylab="Y     (Absolute Error)",
        panel=function(...){
            panel.levelplot(...)
            lpoints(labelled$V1, labelled$V2, pch=1, col=1, cex=1)
            lpoints(newlylabelled$V1, newlylabelled$V2, pch=1, col=2, cex=1)
        }
        )


pp = levelplot(D$P ~ D$X*D$Y, cuts=31,
        colorkey=list(col=rev(heat.colors(32))),
        col.regions=rev(heat.colors(32)), xlab="X",
        ylab="Y     (Prediction)",
        panel=function(...){
            panel.levelplot(...)
            lpoints(labelled$V1, labelled$V2, pch=1, col=1, cex=1)
            lpoints(newlylabelled$V1, newlylabelled$V2, pch=1, col=2, cex=1)
        }
        )

print(ep, split=c(1,1,1,2), more=TRUE)
print(pp, split=c(1,2,1,2), more=TRUE)


# write time series statistics
stats_out = conf("modules.reporter.params.timeseries", "")
if (stats_out != "") {
    card = nrow(labelled)
    res = D$E
    mean_err = mean(abs(res))
    max_err = max(abs(res))
    rmse_err = sqrt(mean(res*res))
    per_err = mean(abs(res)/testset$V3*100)
    max_per_err = max(abs(res)/testset$V3*100)
    sf = file(stats_out, "a")
    writeLines(paste(card, mean_err, max_err, rmse_err, per_err, max_per_err),con=sf,sep="\n")
    close(sf)
}

