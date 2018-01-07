library("ggplot2")
k <- c(2,3,4,5,6,7,8,9,10)
cv <- c(0.52508,0.49786,0.48404,0.48210,0.47220,0.47079,0.47231,0.48261,0.47856)
df <- data.frame(k,cv)
ggplot(df,aes(x=k,y=cv))+
  geom_line()+
  geom_point()+
  #theme_classic()+
  labs(title="Cross-Validation Error Estimate",x="K",y="Cross-Validation Error")+
  scale_x_continuous(limits = c(2,10),breaks = c(2,3,4,5,6,7,8,9,10))+
  theme_light() +
  theme(
    plot.title = element_text(hjust = 0.5,size = 8),
    panel.border = element_rect(color="black"),
    panel.grid.minor = element_blank(),
    axis.text = element_text(size = 8,color = "black"),
    axis.line = element_line(size = 0.5),
    axis.title = element_text(size = 8),
  )
  #scale_color_manual(values = col)
