%% CHRISTOPHER ZERAFA

%% QUESTION
%Simulate the following situation.  Attach the code as part of your submission.
%At a post office, customers enter a single line waiting to be served by any one 
%of two clerks.  Every minute there is a 60% chance that a new customer arrives. 
%If there is no one in line and a server is free, the customer does not wait to be 
%served.  When a customer is being served there is a 25% chance every minute that 
%they complete their business and leave.  When the clerk is free he will take the 
%next customer in line, in the order that they arrived.  Every minute, there is a 
%5% chance that a person standing in line will give up and leave.  The post office 
%is always open (24/7/365). Note: For simplicity you can assume customers will 
%always arrive at the beginning of the minute and if they leave they do so at the 
%end of the minute.

%% SOLUTION

%% PREAMBLE
clc; close all; clear all; format long;

%% PARAMETRIZATION
%INT = 1000;  %small test interval used for QC
INT = 1*60*24*365; %Total time to track
NumClerk = 2; %Number of clerks
p_new=60;    %Probability a new person shows up
p_ready=25; %Probability a person being SERVED completes business and leaves
p_leave=5;  %Probability a person in line leaves 

%% INITIALIZATION
slots=zeros(1,NumClerk); %slots representing number of clerks
waitTime = 0; %total wait time of all customers
queue = 0;  %number of people in queue
leave = 0;  %number of people that left
idle=0; %number of minutes that clerks are idle
cust=0; %number of customers

%% MAIN LOOP
for i=1:INT
  %CHECK IF ANYONE IS DONE FROM BUSINESS AND LEAVES FROM THE CLERKS
  for j=1:NumClerk
    if slots(1,j) == 1
      if randi(100) < p_ready + 1
        slots(1,j) = 0;
      else
        waitTime=waitTime+1;
      end
    end
  end
  %CHECK IF A NEW PERSON WALKS IN POST OFFICE AND IS ADDED TO THE QUEUE
  if randi(100)<p_new +1
    cust=cust+1;
    queue=queue + 1;
  end
  %CHECK IF A PERSON RANDOMLY LEAVES THE QUEUE
  if queue > 0 && randi(100)<p_leave+1
    queue=queue-1;
    leave=leave+1;
  end
  %CHECK IF A PERSON FROM QUEUE CAN BE SERVED
  for j=1:NumClerk
    %CHECK IF CLERK IS FREE
    if slots(1,j)==0
      %CHECK IF PERSON IS IN QUEUE
      if queue > 0
        slots(1,j)=1;
        queue=queue-1;
      end
    end
  end
  %EVERYONE LEFT IN THE QUEUE HAS WAITED ONE MORE INTERVAL TO BE SERVED
  waitTime=waitTime+queue;
  %COUNT THE NUMBER OF TIMES THE CLERKS WERE IDLE
  for j=1:NumClerk
    if slots(1,j) == 0
      idle=idle+1;
    end
  end
  QUEUE(i)= queue; %%matrix for queue plot
end
%%%PLOT ILLUSTRATING THE QUEUE LENGTH
%plot(1:1:INT,QUEUE)
%xlabel("INDEX (minutes)")
%ylabel("QUEUE LENGTH (people)")
%%print -deps -color queue.eps

%%What is the average amount of time a customer spends in the post office (including those not SERVED)?
AVG_TIME_CUSTOMER=waitTime/cust
%% What percentage of customers leave without being served?
PERCENT_CUSTOMERS_LEAVE=leave/cust * 100
%% What percentage of time are the clerks idle?
PERCENT_CLERKS_IDLE=idle/(NumClerk*INT) * 100

