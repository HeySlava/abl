import json
import time
from pathlib import Path

import requests


DATA_FOLDER = Path('./data')
DATA_FOLDER.mkdir(exist_ok=True)
url = 'https://mtgame.ru/api/v1/basketball_statistic/'

tour = 1


while True:

    params = {
            'group_by': 'tournament_team_user',
            'tournament_id': 1032,
            'tournament_tour': tour,
        }

    filename = f'{params["tournament_id"]}_{params["tournament_tour"]}.json'
    path = DATA_FOLDER / filename
    print(path)

    if not path.exists():
        time.sleep(1)
        request = requests.get(url, params=params)
        request.raise_for_status()
        data = request.json()

        if not data:
            break
        with open(path, 'w') as f:
            json.dump(data, f, indent=4, ensure_ascii=False)

    tour += 1
