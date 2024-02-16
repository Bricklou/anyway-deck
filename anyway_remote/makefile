all: gen clean

STEAMAPI_JSON = steam_api.json
LIBSTEAM_API_SO = libsteam_api.so
OUTPUT_DIR = lib/steamworks/src/generated
ARCHIVE = steamworks_sdk_158a.zip
URL = https://partner.steamgames.com/downloads/$(ARCHIVE)

$(ARCHIVE):
	@echo "Downloading Steamworks SDK..."
	@curl -L -o $(ARCHIVE) $(URL)

$(LIBSTEAM_API_SO): $(ARCHIVE)
	@echo "Extracting $(LIBSTEAM_API_SO) from Steamworks SDK..."
	@unzip -p $(ARCHIVE) sdk/redistributable_bin/linux64/$(LIBSTEAM_API_SO) > $(LIBSTEAM_API_SO)

$(STEAMAPI_JSON): $(ARCHIVE)
	@echo "Extracting $(STEAMAPI_JSON) from Steamworks SDK..."
	@unzip -p $(ARCHIVE) sdk/public/steam/$(STEAMAPI_JSON) > $(STEAMAPI_JSON)

gen: $(STEAMAPI_JSON) $(LIBSTEAM_API_SO)
	@echo "Generating flutter_steamworks code..."
	@dart run steamworks_gen -o $(OUTPUT_DIR) $(STEAMAPI_JSON)

clean_all: clean
	@echo "Cleaning up..."
	@rm -rf $(OUTPUT_DIR)
	@rm -f $(STEAMAPI_JSON)
	@rm -f $(LIBSTEAM_API_SO)

clean:
	@echo "Cleaning up..."
	@rm -f $(ARCHIVE)