#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>   
#include <time.h>

#define NUM_PASAJEROS 100
#define NUM_OFICINISTAS 5
#define CAMBIOS_POR_OFICINISTA 3

sem_t mutex;
sem_t wrt;
int lectores = 0;

void* pasajero(void* arg) {
    int id = *((int*)arg);
    
    int delay = rand() % 4;
    sleep(delay);

    sem_wait(&mutex);
    lectores++;
    if (lectores == 1) sem_wait(&wrt);
    sem_post(&mutex);

    printf("Pasajero %d está mirando el cartel\n", id);
    
    sleep(rand() % 4);

    sem_wait(&mutex);
    lectores--;
    if (lectores == 0) sem_post(&wrt);
    sem_post(&mutex);

    free(arg);
    pthread_exit(NULL);
}

void* oficinista(void* arg) {
    int id = *((int*)arg);
    for (int i = 0; i < CAMBIOS_POR_OFICINISTA; i++) {
        int delay = rand() % 6;
        sleep(delay);

        sem_wait(&wrt);
        printf("Oficinista %d está modificando el cartel (cambio %d)\n", id, i+1);
        sleep(rand() % 6);
        sem_post(&wrt);
    }
    free(arg);
    pthread_exit(NULL);
}

int main() {
    srand(time(NULL));
    pthread_t pasajeros[NUM_PASAJEROS];
    pthread_t oficinistas[NUM_OFICINISTAS];

    sem_init(&mutex, 0, 1);
    sem_init(&wrt, 0, 1);

    for (int i = 0; i < NUM_OFICINISTAS; i++) {
        int* id = malloc(sizeof(int));
        *id = i+1;
        pthread_create(&oficinistas[i], NULL, oficinista, id);
    }

    for (int i = 0; i < NUM_PASAJEROS; i++) {
        int* id = malloc(sizeof(int));
        *id = i+1;
        pthread_create(&pasajeros[i], NULL, pasajero, id);
    }

    for (int i = 0; i < NUM_OFICINISTAS; i++)
        pthread_join(oficinistas[i], NULL);

    for (int i = 0; i < NUM_PASAJEROS; i++)
        pthread_join(pasajeros[i], NULL);

    sem_destroy(&mutex);
    sem_destroy(&wrt);

    printf("Todos los pasajeros y oficinistas terminaron.\n");
    return 0;
}