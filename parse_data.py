import json
import csv
from pathlib import Path

from typing import NamedTuple


class User(NamedTuple):
    tournament_team_user_id: int
    team_id: int
    game_time: float
    first_name: str
    last_name: str
    user_id: int
    team_name: str
    sport_id: int
    tour: int


files = Path('./data').glob('*.json')
profiles = []

for f in files:
    _, _, tour = f.stem.rpartition('_')
    tour = int(tour)

    with open(f) as f:
        data = json.load(f)
        profiles += [
                User(
                    tournament_team_user_id=d['tournament_team_user_id'],
                    team_id=d['team_id'],
                    game_time=d['game_time'],
                    first_name=d['tournament_team_user']['league_player']['first_name'],
                    last_name=d['tournament_team_user']['league_player']['last_name'],
                    user_id=d['tournament_team_user']['league_player']['user_id'],
                    team_name=d['tournament_team_user']['tournament_team']['name'],
                    sport_id=d['tournament_team_user']['tournament_team']['team']['sport']['id'],
                    tour=tour,
                )
                for d in data
            ]


filename_csv = './data/users.csv'

header = User._fields
with open(filename_csv, 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(header)
    for user in profiles:
        writer.writerow(user)
