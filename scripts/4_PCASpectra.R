setwd("paintrock_leaf_spectra")
source("Functions/writeSLI_source.R")
source("Functions/lecospectR.R")
require(Polychrome)
require(vegan)
require(glue)

paintrock_spectra_df<-read.csv("output/paintrock_spectra_clean.csv")

taxon_code <- c(unique(paintrock_spectra_df$taxon_code))

taxon_genus<-c("Acer","Acer","Aesculus","Carya","Carya","Diospyros","Fagus","Fraxinus","Gleditsia",
"Juglans","Juniperus","Liquidambar","Liriodendron","Ostrya","Pinus","Platanus","Prunus","Quercus","Quercus","Quercus","Quercus","Quercus","Salix","Tilia","Ulmus","Ulmus","Ulmus")
unique(taxon_genus)
taxa_inf<-as.data.frame(cbind(taxon_code,taxon_genus))

paintrock_spectra_df<-paintrock_spectra_df %>% 
  inner_join(taxa_inf,by="taxon_code", keep=FALSE) %>% 
  dplyr::select(taxon_code,taxon_genus, everything())
dim(paintrock_spectra_df)
taxa_keep=c("Acer","Fagus","Pinus","Quercus")
paintrock_spectra_df=paintrock_spectra_df %>% dplyr::filter(taxon_genus %in% taxa_keep)

tree_list = createPalette(length(unique(paintrock_spectra_df$taxon_code)),  c("#ff0000", "#00ff00", "#0000ff")) %>%
  as.data.frame() %>%
  dplyr::rename(Color = ".") %>%
  mutate(taxon_code = unique(paintrock_spectra_df$taxon_code)) %>%
  mutate(ColorNum = seq(1:length(unique(paintrock_spectra_df$taxon_code))))

tree_genus_list = createPalette(length(unique(paintrock_spectra_df$taxon_genus)),  c("#ff0000", "#00ff00", "#0000ff")) %>%
  as.data.frame() %>%
  dplyr::rename(Color = ".") %>%
  mutate(taxon_genus = unique(paintrock_spectra_df$taxon_genus)) %>%
  mutate(ColorNum = seq(1:length(unique(paintrock_spectra_df$taxon_genus))))

#tree_list<-cbind(taxon_code,tree_palette) %>% as.data.frame()
tree_spectra<-inner_join(paintrock_spectra_df,tree_genus_list, by="taxon_genus", keep=FALSE)
str(tree_spectra)
img_mat<-tree_spectra %>% 
  dplyr::select(-X,-taxon_genus, -taxon_code, -Color, -ColorNum) %>% 
  as.matrix() #%>%
  #as.numeric()

head(img_mat)
  #Multivariate analysis of PFT groups 
tree_adonis<-adonis2(img_mat~as.factor(tree_spectra$taxon_code), method="euclidean", permutations=100)
tree_genus_adonis<-adonis2(img_mat~as.factor(tree_spectra$taxon_genus), method="euclidean", permutations=100)

#
#> tree_adonis
#Permutation test for adonis under reduced model
#Terms added sequentially (first to last)
#Permutation: free
#Number of permutations: 100
#
#adonis2(formula = img_mat ~ as.factor(tree_spectra$taxon_code), permutations = 100, method = "euclidean")
#                                    Df SumOfSqs     R2      F   Pr(>F)   
#as.factor(tree_spectra$taxon_code)  26  8886255 0.5734 13.338 0.009901 **
#Residual                           258  6611102 0.4266                   
#Total                              284 15497357 1.0000                   
#---
#Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1


#> tree_genus_adonis
#Permutation test for adonis under reduced model
#Terms added sequentially (first to last)
#Permutation: free
#Number of permutations: 100
#
#adonis2(formula = img_mat ~ as.factor(tree_spectra$taxon_genus), permutations = 100, method = "euclidean")
#                                     Df SumOfSqs      R2      F   Pr(>F)   
#as.factor(tree_spectra$taxon_genus)  18  8268942 0.53357 16.905 0.009901 **
#Residual                            266  7228416 0.46643                   
#Total                               284 15497357 1.00000                   
#---
#Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
colnames(img_mat)

#img_mat<-as.numeric(img_mat[1:nrow(img_mat),])
#Build PCA with and without sqrt transform
img_pca<-prcomp(img_mat, center = TRUE, scale =TRUE) #, center=FALSE, scale=FALSE)

#img_pca_pr<-prcomp(img_mat[,25:500])#, center=FALSE, scale=FALSE)

#PCA figures with image spectra
#seq(1:length(unique(train_5nm$FncGrp0))) %>% max()
#cols<-palette.colors(n=6)
#train_5nm_reclass<-train_5nm %>% 
#dplyr::mutate(
#        FncGrp0_num = case_when(
#            FncGrp0 ==  "Abiotic" ~ 0,
#            FncGrp0 ==  "BroadleafDecid" ~1,
#            FncGrp0 ==  "ConiferEvergreen" ~2,
#            FncGrp0 ==  "Forb" ~3,
#            FncGrp0 ==  "Graminoid" ~4,
#            FncGrp0 ==  "Lichen" ~5,
#            FncGrp0 ==  "Moss" ~6,
#            FncGrp0 ==  "Unknown" ~7
#        ), .keep = "unused"
#    )
#

##PCA plot Axes 1 vs 2
jpeg("output/PCA_trees_genus_Axes12.jpg")
plot(vegan::scores(img_pca)[,1:2], col=tree_spectra$Color, pch=tree_spectra$ColorNum)
title(main="PCA of PFT Reflectance")
legend(x = 85, y =30, legend=unique(tree_spectra$taxon_genus), lty=1,  pch = unique(tree_spectra$ColorNum),
 col=unique(tree_spectra$Color), cex=0.8)
dev.off()

##PCA plot Axes 2 vs 3
jpeg("output/PCA_trees_Axes23.jpg")
plot(vegan::scores(img_pca)[,2:3], col=tree_spectra$Color, pch=tree_spectra$ColorNum)
title(main="PCA of PFT Reflectance")
legend(x = -55, y =-10, legend=unique(tree_spectra$taxon_genus), lty=1,  pch = unique(tree_spectra$ColorNum), col=unique(tree_spectra$Color), cex=1)
dev.off()

##PCA plot Axes 1 vs 3
jpeg("output/PCA_trees_Axes13.jpg")
plot(vegan::scores(img_pca)[,1]~vegan::scores(img_pca)[,3], col=tree_spectra$Color, pch=tree_spectra$ColorNum)
title(main="PCA of PFT Reflectance")
legend(x = -35, y =120, legend=unique(tree_spectra$taxon_code), lty=1,  pch = unique(tree_spectra$ColorNum), col=unique(tree_spectra$Color), cex=1)
dev.off()

##PCA plot Axes 1 vs 3 : Species within Genera
jpeg("output/PCA_trees_Axes13_species_code.jpg")
plot(vegan::scores(img_pca)[,1]~vegan::scores(img_pca)[,3], col=tree_spectra$Color, pch=tree_spectra$ColorNum)
title(main="PCA of PFT Reflectance")
legend(x = -35, y =120, legend=unique(tree_spectra$taxon_code), lty=1,  pch = unique(tree_spectra$ColorNum), col=unique(tree_spectra$Color), cex=1)
dev.off()

##PCA plot Axes 3 vs 4
jpeg("output/PCA_trees_Axes34.jpg")
plot(vegan::scores(img_pca)[,3]~vegan::scores(img_pca)[,4], col=tree_spectra$Color, pch=tree_spectra$ColorNum)
title(main="PCA of PFT Reflectance")
legend(x = -65, y =65, legend=unique(tree_spectra$taxon_code), lty=1,  pch = unique(tree_spectra$ColorNum), col=unique(tree_spectra$Color), cex=0.5)
dev.off()
