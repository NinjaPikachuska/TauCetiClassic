#define MAX_INSURANCE_PRICE 5000

#define INSURANCE_NONE "None"
#define INSURANCE_STANDARD "Standard"
#define INSURANCE_PREMIUM "Premium"

#define INSURANCE_TIME_ADDITION (max((round((SSeconomy.endtime - world.timeofday) / 600) * 10), 0)) // An additional $10 for every remaining minute before payday
#define INSURANCE_PRICE_CHANGE_CD 5 MINUTES

#define TRANSFER_REQUEST_MAX 5000
#define TRANSFER_COOLDOWN    5 SECONDS
