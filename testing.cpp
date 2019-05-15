#include<vector>
#include<stdio.h>
#include<string>
#include <stdlib.h>
#include <math.h>
#include <ctype.h>
#include <string.h>
#include <time.h>
#include "hleach.h"
#include "const.h"
#include <fstream>
#include <iterator>
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic ignored "-Wunused-value"
#pragma GCC diagnostic ignored "-Wwrite-strings"
#pragma GCC diagnostic ignored "-Wparentheses"
#include <iostream>


using namespace std;

int NUM_NODES = 500;    // number of nodes in the network
                       // default is 50
int NETWORK_X = 500;   // X-size of network
                       // default is 100
int NETWORK_Y = 500;   // Y-size of network
                       // default is 100
double B_POWER = 1.0; // initial battery power of sensors
                       // default is 0.75

double B_HEAD_POWER = 50.0;

// the percentage of the nodes in the
// network that would ideally be cluster
// heads during any one round of the
// LEACH simulation, default is 0.05
double CLUSTER_PERCENT = 0.05; //if we change this make changes in threshold formulae and wherever we have put "20"

// the total rounds that the simulation
// should run for - the network lifetime
// default is 2000
int TOTAL_ROUNDS = 20000;

// the distance that the advertisement
// phase should broadcast to, in order
// to alert other nodes that there is a
// cluster head, default is 25.0
double LEACH_AD_DISTANCE = 25;

// the message length of the advertisement
// that there is a cluster head
// default is 16
int LEACH_AD_MESSAGE = 16;

// the distance for the cluster head to broadcast
// the schedule for transmission to the other nodes
// in the cluster, default is 25.0
double SCHEDULE_DISTANCE = 25;

// the message length of the schedule which is
// sent to the nodes in the cluster during the
// scheduling phase of the LEACH simulation,
// default is 16.

// default rate = 15
double RATE = 15;

int SCHEDULE_MESSAGE = 16;

int BASE_STATION_X_DEFAULT = 5;
int BASE_STATION_Y_DEFAULT = 25;
int BASE_STATION_HEIGHT = 25;

int DEAD_NODE = -2;
int MESSAGE_LENGTH = 8;

int TRIALS = 1;

struct sensor
{
    short xLoc;          // X-location of sensor
    short yLoc;          // Y-location of sensor
    short lPeriods;      // number of periods the sensor
                         // has been in use for
    short ePeriods;      // expected periods the sensor
                         // must be operational for
    double bCurrent;     // current battery power
    double bPower;       // initial battery power
    double pAverage;     // average power consumed per
                         // transmission period.
    int round;           // the last round that the sensor
                         // served as a cluster head
    int head;            // stores the index of the cluster head
                         // for the sensor to transmit to, set to -1 if the
                         // sensor is a cluster head
    int cluster_members; // stores the total number of nodes in
                         // the cluster, applicable only for
                         // cluster head nodes
    int head_count;      // this contains the count of the
                         // number of times a sensor has been
                         // the head of a cluster, can be
                         // removed for optimization later
    bool isDead;
};

struct sensor BASE_STATION;

void initializeNetwork(struct sensor network[]) 
{
    srand((unsigned int)time(0));

    int j = -1;
    for(int i=0;i<NUM_NODES;++i) 
    {
        if((i % 10) == 0)
            ++j;
        network[i].xLoc = (i % 10) + 1;
        network[i].yLoc = j + 1;
        network[i].lPeriods = 0;
        network[i].ePeriods = TOTAL_ROUNDS;
        network[i].bCurrent = B_POWER;
        network[i].bPower = B_POWER;
        network[i].pAverage = 0.00;
        network[i].round = FALSE;
        network[i].head = FALSE;
        network[i].isDead = false;
    }
}

void printNetworkStatus(struct sensor network[])
{
    for(int i=0;i<NUM_NODES;++i)
    {
        if (network[i].head == -1)
            cout << network[i].xLoc << " " << network[i].yLoc <<endl;
        else 
        {
            cout << network[i].head << endl;
        }
    }
}

double avarageEnery(struct sensor network[])
{
    double startingEnergy = 0.0;
    double energy = 0.0;
    for (int i=0; i < NUM_NODES; ++i)
    {
        startingEnergy += network[i].bPower;
        energy += network[i].bCurrent;
    }
    // cout << "Avg Energy: " << energy/startingEnergy << endl;
    return energy/startingEnergy;
}

double computeEnergeTrnasmit(double distance, int messageLength, double rate)
{
    float E_elec = 50 * pow(10, -9);
    float epsilon_amp = 100 * pow(10, -12);
    double EnergyUse = 0.00;

    // rate = rate * 0.1;
    EnergyUse = (messageLength * E_elec) +
                (messageLength * epsilon_amp * pow(distance, 2));

    return EnergyUse * rate;
}

double computeEnergyReceive(int messageLength)
{
    return (messageLength * (50 * pow(10, -9)));
}

void saveNetworkStatus(struct sensor network[], char* filename)
{
    ofstream stats;
    stats.open(filename);
    for(unsigned int i = 0;i < NUM_NODES; ++i) 
    {
        if(network[i].isDead == true)
            stats << network[i].xLoc << " " << network[i].yLoc << " " << "1" << endl;
        else
        {
            stats << network[i].xLoc << " " << network[i].yLoc << " " << "0" << endl;
        }
    }
    stats.close();
}

int runDirectSimulation(struct sensor network[], double rate)
{
    int nodesTransmitting = 0;
    int failedTransmitting = 0;
    double powerConsummed = 0.0;
    int bitsTransmitted = 0;
    int rounds = 0;

    vector<double> avgEnergy;
    saveNetworkStatus(network, "directState0.txt");

    cout << "Running the simulation in direct mode" << endl;
    while (failedTransmitting != NUM_NODES) 
    {
        failedTransmitting = 0;
        for (int i = 0; i < NUM_NODES; i++)
        {
            // cycle through all nodes in network and attempt to
            // transmit
            if (network[i].bCurrent > 0)
            {
                ++nodesTransmitting;
                double distance_X = network[i].xLoc - BASE_STATION.xLoc;
                double distance_Y = network[i].yLoc - BASE_STATION.yLoc;
                double distance = sqrt(pow(distance_X, 2) + pow(distance_Y, 2));
                distance = sqrt(pow(distance, 2) + pow(25, 2));
                powerConsummed = computeEnergeTrnasmit(distance, MESSAGE_LENGTH, rate);
                // cout << "Energy used for transmitting: " << powerConsummed<<endl;
                if (powerConsummed <= network[i].bCurrent)
                {
                    bitsTransmitted += MESSAGE_LENGTH;
                    network[i].bCurrent -= powerConsummed;
                }
                else
                {
                    ++failedTransmitting;
                    network[i].isDead = true;
                    // cout << "failed" << endl;
                }
            }
            if (network[i].bCurrent < 0)
                network[i].bCurrent = 0.0;
        }
        // cout << "avg energy: " << avarageEnery(network) << endl;
        avgEnergy.push_back(avarageEnery(network));
        ++rounds;
        if(rounds == 50000)
        {
            saveNetworkStatus(network,"directState2.txt");
        }
        else if(rounds == 60000)
        {
            saveNetworkStatus(network,"directState3.txt");
        }
    }
    ofstream stats;
    stats.open("directSimulationAvgEnergies.txt");
    for(unsigned int i = 0;i < avgEnergy.size(); ++i) 
    {
        stats << avgEnergy[i] << endl;
    }
    stats.close();

    return rounds;
}

void selectClusterHeads(struct sensor network[])
{
    for(int i=0;i<NUM_NODES;++i)
    {
        int j = i/50;
        j = j*50;
        if((i%10) > 5)
        {
            network[i].head = j + 28;
        }
        else 
        {
            network[i].head = j + 23;
        }
    }

    for(int i=22;i<NUM_NODES;i+=50)
    {
        network[i].head = -1;
        network[i].bPower = B_HEAD_POWER;
        network[i].bCurrent = B_HEAD_POWER;
        network[i+5].head = -1;
        network[i+5].bPower = B_HEAD_POWER;
        network[i+5].bCurrent = B_HEAD_POWER;
    }
}

int runClusterSimulation(struct sensor network[], double rate)
{
    int nodesTransmitting = 0;
    double powerConsumed;
    int bitsTransmitted = 0;
    int rounds = 0;
    vector<double> avgEnerys;
    saveNetworkStatus(network,"clusterState0.txt");

    int deadHeads = 0;
    while(deadHeads != 20)
    {
        deadHeads = 0;
        for(int i=0;i<NUM_NODES;++i)
        {
            if(network[i].head == -1) 
            {
                if(network[i].bCurrent > 0)
                {
                    ++nodesTransmitting;
                    double distance_X = network[i].xLoc - BASE_STATION.xLoc;
                    double distance_Y = network[i].yLoc - BASE_STATION.yLoc;
                    double distance = sqrt(pow(distance_X, 2) + pow(distance_Y, 2));
                    distance = sqrt(pow(distance, 2) + pow(25, 2));
                    powerConsumed = computeEnergeTrnasmit(distance, 25*MESSAGE_LENGTH, rate);
                    if(network[i].bCurrent >= powerConsumed)
                    {
                        bitsTransmitted += 25*MESSAGE_LENGTH;
                        network[i].bCurrent -= powerConsumed;
                    }
                    else
                    {
                        ++deadHeads;
                        network[i].head = true;
                    }
                }
                if (network[i].bCurrent < 0)
                {
                    network[i].bCurrent = 0;
                }
            }
            else
            {
                if(network[i].bCurrent > 0)
                {
                    ++nodesTransmitting;
                    double distance_X = network[i].xLoc - network[network[i].head].xLoc;
                    double distance_Y = network[i].yLoc - network[network[i].head].yLoc;
                    double distance = sqrt(pow(distance_X,2) + pow(distance_Y,2));
                    powerConsumed = computeEnergeTrnasmit(distance, MESSAGE_LENGTH, rate);
                    if(network[i].bCurrent >= powerConsumed)
                    {
                        bitsTransmitted += MESSAGE_LENGTH;
                        network[i].bCurrent -= powerConsumed;
                        double receverPower = computeEnergyReceive(MESSAGE_LENGTH);
                        if(network[network[i].head].bCurrent >= receverPower)
                        {
                            network[network[i].head].bCurrent -= receverPower;
                        }
                    }
                    else
                    {
                        network[i].isDead = true;
                    }
                    
                }
                if(network[i].bCurrent < 0)
                    network[i].bCurrent = 0;
            }
        }
        // cout << "DeadHeads : " << deadHeads << endl;
        avgEnerys.push_back(avarageEnery(network));
        ++rounds;
        if(rounds == 120000)
        {
            saveNetworkStatus(network,"clusterState1.txt");
        }
        if(rounds == 130000)
        {
            saveNetworkStatus(network,"clusterState2.txt");
        }
    }
    ofstream stats;
    stats.open("clusterSimulationAvgEnergies.txt");
    for(unsigned int i = 0;i < avgEnerys.size(); ++i) 
    {
        stats << avgEnerys[i] << endl;
    }
    stats.close();

    return rounds;
}

void convertTo2Layer(struct sensor network[])
{
    BASE_STATION.xLoc = 5;
    BASE_STATION.yLoc = 13;
    int j = -1;
    bool flag = true;
    for(int i=0;i<NUM_NODES;i++)
    {
        if((i % 10) == 0)
            ++j;
        if (j == 25 && flag)
        {
            flag = false;
            j = 0;
        }
        network[i].xLoc = (i % 10) + 1;
        network[i].yLoc = j + 1;
    }
}

void incresePowerTo2Layer(struct sensor network[])
{
    for(int i=272;i< NUM_NODES;i+=50)
    {
        network[i].bPower = 2*B_HEAD_POWER;
        network[i].bCurrent = 2*B_HEAD_POWER;
        network[i+5].bPower = 2*B_HEAD_POWER;
        network[i+5].bCurrent = 2*B_HEAD_POWER;
    }
}

int runCluster2LayerSimulation(struct sensor network[], double rate)
{
    int nodesTransmitting = 0;
    double powerConsumed;
    int bitsTransmitted = 0;
    int rounds = 0;
    vector<double> avgEnerys;

    int deadHeads = 0;
    while(deadHeads != 20)
    {
        deadHeads = 0;
        for(int i=0;i<NUM_NODES;++i)
        {
            if(network[i].head == -1 && i>250) 
            {
                if(network[i].bCurrent > 0)
                {
                    ++nodesTransmitting;
                    double distance_X = network[i].xLoc - BASE_STATION.xLoc;
                    double distance_Y = network[i].yLoc - BASE_STATION.yLoc;
                    double distance = sqrt(pow(distance_X, 2) + pow(distance_Y, 2));
                    distance = sqrt(pow(distance, 2) + pow(10, 2));
                    powerConsumed = computeEnergeTrnasmit(distance, 2*25*MESSAGE_LENGTH, rate);
                    if(network[i].bCurrent >= powerConsumed)
                    {
                        bitsTransmitted += 2*25*MESSAGE_LENGTH;
                        network[i].bCurrent -= powerConsumed;
                    }
                    else
                    {
                        ++deadHeads;
                        network[i].isDead = true;
                    }
                }
                if (network[i].bCurrent < 0)
                {
                    network[i].bCurrent = 0;
                }
            }
            else if(network[i].head == -1) 
            {
                if(network[i].bCurrent > 0)
                {
                    ++nodesTransmitting;
                    double distance = 15;
                    powerConsumed = computeEnergeTrnasmit(distance, 25*MESSAGE_LENGTH, rate);
                    if(network[i].bCurrent >= powerConsumed)
                    {
                        bitsTransmitted += 25*MESSAGE_LENGTH;
                        network[i].bCurrent -= powerConsumed;
                    }
                    else
                    {
                        ++deadHeads;
                        network[i].isDead = true;
                    }
                }
                if (network[i].bCurrent < 0)
                {
                    network[i].bCurrent = 0;
                }
            }
            else
            {
                if(network[i].bCurrent > 0)
                {
                    ++nodesTransmitting;
                    double distance_X = network[i].xLoc - network[network[i].head].xLoc;
                    double distance_Y = network[i].yLoc - network[network[i].head].yLoc;
                    double distance = sqrt(pow(distance_X,2) + pow(distance_Y,2));
                    powerConsumed = computeEnergeTrnasmit(distance, MESSAGE_LENGTH, rate);
                    if(network[i].bCurrent >= powerConsumed)
                    {
                        bitsTransmitted += MESSAGE_LENGTH;
                        network[i].bCurrent -= powerConsumed;
                        double receverPower = computeEnergyReceive(MESSAGE_LENGTH);
                        if(network[network[i].head].bCurrent >= receverPower)
                        {
                            network[network[i].head].bCurrent -= receverPower;
                        }
                    }
                    network[i].isDead = true;
                }
                if(network[i].bCurrent < 0)
                    network[i].bCurrent = 0;
            }
        }
        // cout << "DeadHeads : " << deadHeads << endl;
        avgEnerys.push_back(avarageEnery(network));
        ++rounds;
    }
    ofstream stats;
    stats.open("cluster2LayerSimulationAvgEnergies.txt");
    for(unsigned int i = 0;i < avgEnerys.size(); ++i) 
    {
        stats << avgEnerys[i] << endl;
    }
    stats.close();
}

int main() 
{
    struct sensor *network = (struct sensor*)malloc(NUM_NODES * sizeof(struct sensor));

    BASE_STATION.xLoc = BASE_STATION_X_DEFAULT;
    BASE_STATION.yLoc = BASE_STATION_Y_DEFAULT;
    
    // vector<int> directRoundsRates;

    // for(double rate = 1;rate<50;rate += 1)
    // {
        // initializeNetwork(network);
        // int directRounds = runDirectSimulation(network, RATE);
        // cout << "Successfully completed direct rounds of " << directRounds << endl;
        // directRoundsRates.push_back(directRounds);
    // }
    // ofstream stats;
    // stats.open("directSimulationRateVaries.txt");
    // for(unsigned int i = 0;i < directRoundsRates.size(); ++i) 
    // {
    //     stats << directRoundsRates[i] << endl;
    // }
    // stats.close();


    // vector<int> clusterRoundsRates;
    // for(double rate = 1;rate<50;rate += 1)
    // {
        initializeNetwork(network);
        selectClusterHeads(network);
        // printNetworkStatus(network);
        int clusterRounds = runClusterSimulation(network, RATE);
        cout << "Successfully completed cluster head rounds of " << clusterRounds << endl;
    //     clusterRoundsRates.push_back(clusterRounds);
    // }
    // ofstream stats2;
    // stats2.open("clusterSimulationRateVaries.txt");
    // for(unsigned int i = 0;i < directRoundsRates.size(); ++i) 
    // {
    //     stats2 << directRoundsRates[i] << endl;
    // }
    // stats2.close();

    // vector<int> cluster2LayerRoundsRates;
    // for(double rate = 1;rate<2;rate += 1)
    // {
    //     initializeNetwork(network);
    //     convertTo2Layer(network);
    //     selectClusterHeads(network);
    //     incresePowerTo2Layer(network);
    //     int cluster2LayerRounds = runCluster2LayerSimulation(network, RATE);
    //     cout << "successfully completed cluster 2layer rounds of: " << cluster2LayerRounds << endl;
    //     cluster2LayerRoundsRates.push_back(cluster2LayerRounds);
    // }

    // ofstream stats2;
    // stats2.open("cluster2LayerSimulationRateVaries.txt");
    // for(unsigned int i = 0;i < cluster2LayerRoundsRates.size(); ++i) 
    // {
    //     stats2 << cluster2LayerRoundsRates[i] << endl;
    // }
    // stats2.close();

}