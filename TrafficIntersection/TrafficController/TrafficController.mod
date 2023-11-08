MODEL
MODEL_VERSION "v1998.8";
DESIGN "TrafficController";

/* port names and type */
INPUT S:PIN1 = clock;
INPUT S:PIN30 = reset;
INPUT S:PIN34 = CarEW;
INPUT S:PIN36 = CarNS;
INPUT S:PIN37 = PedEW;
INPUT S:PIN38 = PedNS;
OUTPUT S:PIN40 = LightsEW<0>;
OUTPUT S:PIN39 = LightsEW<1>;
OUTPUT S:PIN42 = LightsNS<0>;
OUTPUT S:PIN41 = LightsNS<1>;

/* timing arc definitions */
clock_LightsEW<0>_delay: DELAY clock LightsEW<0>;
clock_LightsEW<1>_delay: DELAY clock LightsEW<1>;
clock_LightsNS<0>_delay: DELAY clock LightsNS<0>;
clock_LightsNS<1>_delay: DELAY clock LightsNS<1>;

/* timing check arc definitions */
ENDMODEL
