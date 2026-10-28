library(tidyverse)

aed <- read.table("output/MAKER/final/assembly.all.maker.renamed.gff.AED.txt",
                  header = TRUE, sep = "", check.names = FALSE)
colnames(aed) <- c("AED", "cumulative")

p <- ggplot(aed, aes(x = AED, y = cumulative)) +
  geom_line(linewidth = 1, colour = "steelblue") +
  geom_vline(xintercept = 0.5, linetype = "dashed", colour = "firebrick") +
  geom_hline(yintercept = 0.9, linetype = "dotted", colour = "grey40") +
  scale_x_continuous(limits = c(0, 1)) +
  scale_y_continuous(limits = c(0, 1)) +
  labs(x = "AED", y = "Cumulative fraction of gene models",
       title = "Cumulative AED distribution of MAKER gene models") +
  theme_classic()

dir.create("plots", showWarnings = FALSE)
ggsave("plots/AED_cumulative.pdf", p, width = 6, height = 5)

# fraction of models with AED <= 0.5
print(aed[aed$AED == 0.5, ])