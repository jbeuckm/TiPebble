#include "pebble.h"

static Window *window;

static TextLayer *temperature_layer;
static char temperature[16];

static BitmapLayer *image_layer;
static GBitmap *image_bitmap = NULL;


static AppSync sync;

#define PHONEBUFFERSIZE 95
#define BUFFEROFFSET (PHONEBUFFERSIZE-1)
#define BITMAPWIDTH 128 // we're assuming square BITMAPS
#define BITMAPSIZE (BITMAPWIDTH * BITMAPWIDTH / 8)     // 128x128/8    

static uint8_t bitmap_data[BITMAPSIZE]; 
static GBitmap display_bitmap;


enum WeatherKey {
  WEATHER_ICON_KEY = 0x0,         // TUPLE_INT
  WEATHER_TEMPERATURE_KEY = 0x1,  // TUPLE_CSTRING
  BITMAP_KEY = 0x2,  // TUPLE_CSTRING
};


void get_image (Tuple *bitmap_tuple) {
    bool done = false;
    if (bitmap_tuple) {
        if (bitmap_tuple->type == TUPLE_BYTE_ARRAY){
            size_t offset = bitmap_tuple->value->data[0] * BUFFEROFFSET;
            memcpy(bitmap_data + offset, bitmap_tuple->value->data + 1, bitmap_tuple->length - 1);

            if (bitmap_tuple->length - 1 < BUFFEROFFSET) {
                done=true;
                }
            }
        }
        
    if (done) {
        APP_LOG(APP_LOG_LEVEL_DEBUG, " - - get_image Done! %s", "");
    
      //  display_bitmap = gbitmap_create_with_data(bitmap_data);
        
   display_bitmap = (GBitmap) {  // Katharine's code set this explicitly.  The method above should handle it.
        .addr = bitmap_data,
        .bounds = GRect(0, 0, BITMAPWIDTH, BITMAPWIDTH),
        .info_flags = 1,
        .row_size_bytes = BITMAPWIDTH/8,
    };

        bitmap_layer_set_bitmap(image_layer, &display_bitmap);
    }
}




static void in_received_handler(DictionaryIterator *iter, void *context) {
  Tuple *bitmap_tuple = dict_find(iter, BITMAP_KEY);
  Tuple *temp_tuple = dict_find(iter, WEATHER_TEMPERATURE_KEY);
  Tuple *icon_tuple = dict_find(iter, WEATHER_ICON_KEY);

  if (icon_tuple) {
      APP_LOG(APP_LOG_LEVEL_DEBUG, "Icon msg: %s", "");
  }
  if (temp_tuple) {
    APP_LOG(APP_LOG_LEVEL_DEBUG, "Temp msg: %s", "");
    text_layer_set_text(temperature_layer, temp_tuple->value->cstring);
  }
  if (bitmap_tuple) {
    get_image (bitmap_tuple);
  }
}

static void in_dropped_handler(AppMessageResult reason, void *context) {
  APP_LOG(APP_LOG_LEVEL_DEBUG, "App Message Dropped! : %d", reason);
}

static void out_failed_handler(DictionaryIterator *failed, AppMessageResult reason, void *context) {
    APP_LOG(APP_LOG_LEVEL_DEBUG, "App Message Failed to Send!");
}


static void app_message_init(void) {
  // Register message handlers
  app_message_register_inbox_received(in_received_handler);
  app_message_register_inbox_dropped(in_dropped_handler);
  app_message_register_outbox_failed(out_failed_handler);
  // Init buffers
  app_message_open(105, 105);
}


static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);

  image_layer = bitmap_layer_create(GRect(10, 10, BITMAPWIDTH, BITMAPWIDTH));
  layer_add_child(window_layer, bitmap_layer_get_layer(image_layer));

  temperature_layer = text_layer_create(GRect(0, 100, 144, 68));
  text_layer_set_text_color(temperature_layer, GColorWhite);
  text_layer_set_background_color(temperature_layer, GColorClear);
  text_layer_set_font(temperature_layer, fonts_get_system_font(FONT_KEY_GOTHIC_28_BOLD));
  text_layer_set_text_alignment(temperature_layer, GTextAlignmentCenter);
  text_layer_set_text(temperature_layer, temperature);

  layer_add_child(window_layer, text_layer_get_layer(temperature_layer));
}


static void window_unload(Window *window) {
  app_sync_deinit(&sync);
  if (image_bitmap) {
    gbitmap_destroy(image_bitmap);
  }
  text_layer_destroy(temperature_layer);
  bitmap_layer_destroy(image_layer);
}


static void init() {
  window = window_create();
  window_set_background_color(window, GColorBlack);
  window_set_fullscreen(window, true);
  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload
  });

  app_message_init();    

  const bool animated = true;
  window_stack_push(window, animated);
}

static void deinit() {
  window_destroy(window);
}

int main(void) {
  init();
  app_event_loop();
  deinit();
}
