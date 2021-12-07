#install packages
install.packages("tidyverse")
install.packages("plyr")
library(tidyverse)
library(plyr)

#set wd
setwd("/Users/tongj/Documents/R/merge_filter")
list.files(getwd())

survey_df <- read_csv("survey_winter_potencial_leads.csv")
names(survey_df) <- "email"
survey_df_email <- survey_df[,1]
reminder_a <- read_csv("members_Reminder_20_Off_Holiday_Sale_W21_22_JA__sent_Dec_3_2021.csv")
names(reminder_a) <- "email"
reminder_a_email <- reminder_a[,1]
reminder_b <- read_csv("members_Reminder_20_Off_Holiday_Sale_W21_22_JA_Additional_Audience__sent_Dec_3_2021.csv")
names(reminder_b) <- "email"
reminder_b_email <- reminder_b[,1]
reminder_a1 <- read_csv("members_20_Off_Holiday_Sale_W21_22_JA__sent_Dec_3_2021.csv")
names(reminder_a1) <- "email"
reminder_a1_email <- reminder_a1[,1]
reminder_b1 <- read_csv("members_20_Off_Holiday_Sale_W21_22_JA_Additional_Audience__sent_Dec_3_2021.csv")
names(reminder_b1) <- "email"
reminder_b1_email <- reminder_b1[,1]
repeater <- read_csv("members_Repeater_S_Discount_Reminder_W21_22_JA__sent_Dec_3_2021.csv")
names(repeater) <- "email"
repeater_email <- repeater[,1]
do_not_contact_repeater <- read_csv("RoomBoss_PCRPI (7).csv")
names(do_not_contact_repeater) <- "email"
do_not_contact_repeater_email <- do_not_contact_repeater[,1]
do_not_contact_cleaned <- read_csv("cleaned_segment_export_8f06201feb.csv")
names(do_not_contact_cleaned) <- "email"
do_not_contact_cleaned_email <- do_not_contact_cleaned[,1]
do_not_contact_archived <- read_csv("archived_export_67c610870e.csv")
names(do_not_contact_archived) <- "email"
do_not_contact_archived_email <- do_not_contact_archived[,1]


#temp1 <- merge(survey_df, reminder_a, by.x = "email")
#temp3 <- survey_df[!(survey_df$email %in% temp1$email),]

#rename data frame
#dfs <- c("survey_df", "reminder_a", "reminder_a1", "reminder_b", "reminder_b1", "repeater", "do_not_contact_repeater")

#for(df in dfs) {
#  df.tmp <- get(df)
#  names(df.tmp) <- c("email") 
#  assign(df, df.tmp)
#}
all_obser_email <-bind_rows(survey_df_email, reminder_a_email, reminder_a1_email, reminder_b_email, reminder_b1_email, repeater_email)
all_campaign_email <-bind_rows(reminder_a_email, reminder_a1_email, reminder_b_email, reminder_b1_email, repeater_email)

#####
all_obser1 <- bind_rows(survey_df[,1], reminder_a[,1], reminder_a1[,1], reminder_b[,1], reminder_b1[,1], repeater[,1])
all_obser2 <- c(all_obser1[,1], all_obser1[,2])
all_obser2 <- rbind.fill(survey_df[,1], reminder_a[,1], reminder_a1[,1], reminder_b[,1], reminder_b1[,1], repeater[,1])
MyList <- list(survey_df[,1], reminder_a[,1], reminder_a1[,1], reminder_b[,1], reminder_b1[,1], repeater[,1])
#####

#test temp2 <- duplicated(temp1[,1])
#test temp4 <- temp1 %>% duplicated(email)
#test temp3 <- temp1*temp2

#count the occurance using group_by

#head(all_obser_email)
all_ober1_occurance <- all_campaign_email %>%
  group_by(email) %>%
  dplyr::summarize(n = n()) %>%
  mutate(Freq = n/sum(n))

#build consolidated report
survey_fre <- merge(survey_df, all_ober1_occurance, by.x = "email")
#relocate columns
survey_fre <- survey_fre %>% relocate(n, .after = email)

# exclude contacts who has been contacted already
############## CAREFUL WITH UNSUBBED ################
sales_mail_unsub <- read_csv("unsubscribed_segment_export_fd3b313834.csv")
#mail chimp multiple campaign
sales_mail_sent <- read_csv("subscribed_segment_export_fd3b313834.csv")
do_not_contact <- bind_rows(sales_mail_sent[,1], sales_mail_unsub[,1])
#direct export from FS campaign
do_not_contact <- read_csv("fsales_report_196154_12000039822_12000038411__07_12_2021_02_17_14.csv")
do_not_contact_email <- do_not_contact[,4]
do_not_contact_email <- `colnames<-`(do_not_contact_email, "email")
names(do_not_contact_cleaned) <- paste("email")
names(do_not_contact_archived) <- paste("email")

do_not_contact_all <- bind_rows(do_not_contact_email, do_not_contact_cleaned[,1], do_not_contact_archived[,1], do_not_contact_repeater)
survey_quality_contacts <- survey_fre[!(survey_fre$email %in% do_not_contact_all$email),]
n_temps <- read_csv("survey_edm_open_frequency_exclude_contacted_existing_booking_v2.csv")
names(survey_quality_contacts) <- names(n_temps)

#winter existing bookings
#survey_quality_contacts1 <- survey_quality_contacts[!(survey_quality_contacts$email %in% do_not_contact_repeater$email),]


#export with csv file
write_csv(survey_fre, "survey_edm_open_frequency.csv")
write_csv(survey_fre, "survey_edm_open_frequency_exclude_contacted.csv")
write_csv(survey_quality_contacts, "survey_edm_open_frequency_exclude_contacted_existing_booking_v3.csv")


