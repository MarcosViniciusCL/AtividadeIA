import threading
import websocket
import _thread
import time
import rel

import neat

redes = []
lista_genomas = []
naves = []

    

def ativar( id, sensor, fitness, vivo):
    lista_genomas[id].fitness = fitness
    output = redes[id].activate(sensor)
    if not vivo:
        naves.remove(id)
        print("Nave " + str(id) + " destruída")
    return output

def on_message(ws, message):
    msg = str(message).replace("b'", "").replace("'", "")
    # print(msg)

    o = msg.split(":")
    id = int(o[0])
    sensor = o[1].split(",")
    sensor = [float(i) for i in sensor]
    fitness = float(o[2])
    sensor.append(float(o[3]))
    vivo = o[4] == "1"

    output = ativar(id, sensor, fitness, vivo)
    
    md = "md" if output[0] > 0.5 else ""
    me = "me" if output[1] > 0.5 else ""
    mc = "mc" if output[2] > 0.5 else ""
    mb = "mb" if output[3] > 0.5 else ""
    at = "at" if output[4] > 0.5 else ""

    env = [md, me, mc, mb, at]
    for i in env:
        if i != "":
            send_msg(str(id) + ":" + i)

def on_error(ws, error):
    print(error)

def on_close(ws, close_status_code, close_msg):
    print("### closed ###")

def on_open(ws):
    print("Opened connection")

def send_msg(msg):
    ws.send(msg)


def criar_nave(id):
    send_msg("create:" + str(id))

def main(genomes, config):
    send_msg("restart")
    # lista_genomas = []
    # redes = []
    index = 0
    for _, genome in genomes:
        redes.append(neat.nn.FeedForwardNetwork.create(genome, config))
        genome.fitness = 0
        lista_genomas.append(genome)
        naves.append(index)
        criar_nave(index)
        index += 1
    while len(naves) > 0:
        time.sleep(0.1)


def conectar(n):

    config = neat.config.Config(neat.DefaultGenome, neat.DefaultReproduction, neat.DefaultSpeciesSet, neat.DefaultStagnation, "./config.txt")
    populacao = neat.Population(config)
    populacao.add_reporter(neat.StdOutReporter(True))
    populacao.add_reporter(neat.StatisticsReporter())
    populacao.run(main, 50)
   

if __name__ == "__main__":
     # Set dispatcher to automatic reconnection
    

    ws = websocket.WebSocketApp("ws://127.0.0.1:9080",
                              on_open=on_open,
                              on_message=on_message,
                              on_error=on_error,
                              on_close=on_close)

    ws.run_forever(dispatcher=rel)

    x = threading.Thread(target=conectar, args=(1,))
    x.start()
   
    rel.signal(2, rel.abort)  # Keyboard Interrupt
    rel.dispatch()


