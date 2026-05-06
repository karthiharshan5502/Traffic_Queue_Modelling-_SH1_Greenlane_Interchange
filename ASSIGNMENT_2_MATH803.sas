DATA X;
CALL streaminit(123); /* Initialize random number stream with seed 123 */  
DO i = 1 to 20; /* Loop 100 times */
lamda = rand("Poisson", 22.5); /*Poisson distribution with mean 22.5*/        
mu = rand("EXPONENTIAL", 25.35); /*Exponential distribution with mean 25.35*/        
rho = lamda / (2 * mu); /* Calculate the rho value */
P = 1/(1+(rho**2/(2*(1 - rho))));
Lq = ((((lamda/mu)**2)*rho)/(2*((1-rho)**2)))*P;
Wq = Lq / lamda;
W = Wq + (1/mu);
L = Lq + (lamda/mu);        
IF rho <= 1 THEN DO; /* Check if rho is less than or equal to 1 */;
OUTPUT;/* Output the generated values */
END;
END;
RUN;
proc means data = X;
var rho P Lq Wq W L;
run;
proc sgplot data=x;
    title 'Queue Performance Metrics';
    series x=i y=L / legendlabel='Average Number of Customers in the System (L)' lineattrs=(color=blue);
    series x=i y=W / legendlabel='Average Time in the System (W)' lineattrs=(color=red);
    series x=i y=Lq / legendlabel='Average Number of Customers in the Queue (Lq)' lineattrs=(color=green);
    series x=i y=Wq / legendlabel='Average Wait Time in the Queue (Wq)' lineattrs=(color=orange);
    xaxis label='Iteration';
    yaxis label='Value';
run;