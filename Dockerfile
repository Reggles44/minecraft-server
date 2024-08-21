FROM eclipse-temurin:21-jre AS server

WORKDIR /data

# Install Tooling
RUN apt update
COPY --from=docker.io/itzg/rcon-cli:latest /rcon-cli /usr/local/bin/rcon-cli
RUN apt update && apt install -y rsync gosu webp adduser && rm -rf /var/lib/apt/lists/*

# Download the server jar
ENV PAPER_VERSION="1.21.1"
ENV PAPER_BUILD="33"
ADD "https://papermc.io/api/v2/projects/paper/versions/${PAPER_VERSION}/builds/${PAPER_BUILD}/downloads/paper-${PAPER_VERSION}-${PAPER_BUILD}.jar" /opt/minecraft/paperspigot.jar

# Enviorment Vars
ENV MEMORYSIZE="1G"
ENV JAVAFLAGS="-Dlog4j2.formatMsgNoLookups=true -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=mcflags.emc.gs -Dcom.mojang.eula.agree=true"
ENV PAPERMC_FLAGS="--nojline"

# Expose Port
EXPOSE 25565/tcp 25565/udp

# Add the entrypoint
COPY /docker-entrypoint.sh /opt/minecraft
RUN chmod +x /opt/minecraft/docker-entrypoint.sh 

# Run entrypoint
ENTRYPOINT ["/opt/minecraft/docker-entrypoint.sh"]
# ENTRYPOINT java -jar -Xms$MEMORYSIZE -Xmx$MEMORYSIZE ${JAVAFLAGS} /opt/minecraft/paperspigot.jar ${PAPERMC_FLAGS} --nogui

