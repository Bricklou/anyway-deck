all: gen

STEAMAPI_JSON = steam_api.json
STEAMAPI_JSON_PATH = steamworks/$(STEAMAPI_JSON)
LIBSTEAM_API_SO = libsteam_api.so
LIBSTEAM_API_SO_PATH = steamworks/$(LIBSTEAM_API_SO)
OUTPUT_DIR = lib/steamworks/src/generated
ARCHIVE = steamworks_sdk_159.zip
ARCHIVE_FILE = steamworks/$(ARCHIVE)
URL = https://partner.steamgames.com/downloads/$(ARCHIVE)

$(ARCHIVE_FILE):
	@echo "Downloading Steamworks SDK... ($(ARCHIVE))"
	@curl -fL -o $(ARCHIVE_FILE) "$(URL)"

$(LIBSTEAM_API_SO_PATH): $(ARCHIVE_FILE)
	@echo "Extracting $(LIBSTEAM_API_SO) from Steamworks SDK..."
	@unzip -p $(ARCHIVE_FILE) sdk/redistributable_bin/linux64/$(LIBSTEAM_API_SO) > $(LIBSTEAM_API_SO_PATH)

$(STEAMAPI_JSON_PATH): $(ARCHIVE_FILE)
	@echo "Extracting $(STEAMAPI_JSON) from Steamworks SDK..."
	@unzip -p $(ARCHIVE_FILE) sdk/public/steam/$(STEAMAPI_JSON) > $(STEAMAPI_JSON_PATH)

gen: $(STEAMAPI_JSON_PATH) $(LIBSTEAM_API_SO_PATH)
	@echo "Generating flutter_steamworks code..."
	@dart run steamworks_gen -o $(OUTPUT_DIR) $(STEAMAPI_JSON_PATH)
	@patch -i ./steamworks/dl_dart.patch -u ./lib/steamworks/src/generated/dl.dart --forward
	@patch -i ./steamworks/steam_api_dart.patch -u ./lib/steamworks/src/generated/initializers/steam_api.dart

clean: 
	@echo "Cleaning up..."
	@rm -f $(ARCHIVE_FILE)
	@rm -rf $(OUTPUT_DIR)
	@rm -f $(STEAMAPI_JSON_PATH)
	@rm -f $(LIBSTEAM_API_SO_PATH)

run:
	@echo "Run program..."
	@flutter run --dart-define=STEAM_API_PATH=$(shell pwd)/steamworks

copy_vdf:
	@mkdir -p /home/$(USER)/.local/share/Steam/controller_config
	@cp -r steamworks/controller_config/anyway_deck.vdf /home/$(USER)/.local/share/Steam/controller_config/game_actions_480.vdf

remove_vdf:
	@rm -f /home/$(USER)/.local/share/Steam/controller_config/game_actions_480.vdf