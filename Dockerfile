FROM nvcr.io/nvidia/rapidsai/notebooks:26.04-cuda13-py3.14

ENV HOME="/home/jovyan"

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends tini tmux \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir jupyterhub marimo marimo-jupyter-extension

USER rapids

COPY --chmod=0755 start-notebook.py entrypoint.sh /usr/local/bin/

WORKDIR /home/jovyan

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["start-notebook.py"]
