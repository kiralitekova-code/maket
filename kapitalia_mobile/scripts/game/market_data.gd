class_name MarketData
extends Node

# ==============================================================================
# KAPITALIA Mobile — Mock-данные товаров, котировки и стакан (глубина 3×3)
# Обновление котировок каждые 0.8 сек (симуляция биржевого тика)
# ==============================================================================

signal quotes_updated()
signal orderbook_updated(commodity_id: String)

# ── Комmodity (товар) ──
class Commodity:
	var id: String
	var name: String
	var category: String  # "grain", "flour", "sugar", "fuel", "bread"
	var icon: String
	var base_price: float
	var price: float
	var delta: float  # % за последний тик
	var trend: String  # "up", "down", "flat"
	var volume_24h: float  # оборот за 24ч (тонны)
	var spread: float  # спред %
	
	func _init(p_id: String, p_name: String, p_category: String, p_icon: String, p_base: float) -> void:
		id = p_id
		name = p_name
		category = p_category
		icon = p_icon
		base_price = p_base
		price = p_base
		delta = 0.0
		trend = "flat"
		volume_24h = randf_range(100.0, 2000.0)
		spread = randf_range(0.1, 0.8)

# ── Уровень стакана ──
class OrderBookLevel:
	var price: float
	var volume: float  # тонны
	var orders: int  # кол-во ордеров
	
	func _init(p_price: float, p_volume: float, p_orders: int) -> void:
		price = p_price
		volume = p_volume
		orders = p_orders

# ── Стакан 3×3 (3 бида, 3 аска) ──
class OrderBook:
	var commodity_id: String
	var bids: Array[OrderBookLevel]  # покупатели (от высокой к низкой)
	var asks: Array[OrderBookLevel]  # продавцы (от низкой к высокой)
	
	func _init(p_id: String) -> void:
		commodity_id = p_id
		bids = []
		asks = []

# ── Регистрация товаров ──
var commodities: Dictionary = {}  # id -> Commodity
var orderbooks: Dictionary = {}   # id -> OrderBook

# Таймер обновления
var _ticker: Timer

# Предопределённые города (для M9)
enum City {
	NORDHEIM,  # промышленный хаб
	WALLEN,    # аграрный хаб
	KRONSTADT, # морской порт
	OSTERWICK  # горнодобывающий
}

var city_names: Array[String] = ["Нордхейм", "Валлен", "Кронстад", "Остервик"]
var city_demands: Dictionary = {}  # city -> { commodity_id: demand_tons_per_week }
var city_stocks: Dictionary = {}   # city -> { commodity_id: stock_tons }


func _ready() -> void:
	_register_commodities()
	_init_cities()
	_update_all_orderbooks()
	
	_ticker = Timer.new()
	_ticker.wait_time = 0.8
	_ticker.one_shot = false
	_ticker.timeout.connect(_on_ticker_tick)
	add_child(_ticker)
	_ticker.start()


# ── Регистрация всех товаров ──
func _register_commodities() -> void:
	_add("grain_wheat",        "Пшеница мягкая",       "grain",  "🌾", 1_420.0)
	_add("grain_rye",          "Рожь яровая",          "grain",  "🌾", 1_180.0)
	_add("flour_premium",      "Мука пшеничная в/с",    "flour",  "🍚", 2_950.0)
	_add("flour_standard",     "Мука пшеничная 1 с",    "flour",  "🍚", 2_340.0)
	_add("sugar_white",        "Сахар-песок",           "sugar",  "🧂", 5_420.0)
	_add("diesel_l62",         "Топливо синтетическое", "fuel",   "⛽", 14_200.0)
	_add("bread_wheat",        "Хлеб пшеничный",        "bread",  "🍞", 4_800.0)
	_add("bread_rye",          "Хлеб ржаной",           "bread",  "🍞", 3_600.0)
	_add("fertilizer_np",      "Удобрение азотное",     "raw",    "🧪", 8_100.0)
	_add("packaging_carton",   "Упаковка картонная",    "raw",    "📦", 1_200.0)


func _add(id: String, name: String, category: String, icon: String, base: float) -> void:
	var c := Commodity.new(id, name, category, icon, base)
	commodities[id] = c


# ── Инициализация городов (M9) ──
func _init_cities() -> void:
	# Нордхейм — промышленный хаб, высокий спрос на хлеб и топливо
	city_demands[City.NORDHEIM] = {
		"bread_wheat": 240.0,
		"flour_premium": 600.0,
		"diesel_l62": 180.0,
		"sugar_white": 120.0,
		"grain_wheat": 80.0,
	}
	city_stocks[City.NORDHEIM] = {
		"bread_wheat": 45.0,
		"flour_premium": 14.2,
		"diesel_l62": 85.0,
		"sugar_white": 28.0,
		"grain_wheat": 60.0,
	}
	
	# Валлен — аграрный хаб, много зерна
	city_demands[City.WALLEN] = {
		"grain_wheat": 400.0,
		"flour_premium": 150.0,
		"fertilizer_np": 90.0,
		"diesel_l62": 200.0,
	}
	city_stocks[City.WALLEN] = {
		"grain_wheat": 820.0,
		"flour_premium": 210.0,
		"fertilizer_np": 35.0,
		"diesel_l62": 60.0,
	}
	
	# Кронстад — морской порт, экспорт/импорт
	city_demands[City.KRONSTADT] = {
		"bread_wheat": 180.0,
		"sugar_white": 300.0,
		"packaging_carton": 150.0,
		"grain_rye": 200.0,
	}
	city_stocks[City.KRONSTADT] = {
		"bread_wheat": 95.0,
		"sugar_white": 420.0,
		"packaging_carton": 78.0,
		"grain_rye": 110.0,
	}
	
	# Остервик — горнодобывающий
	city_demands[City.OSTERWICK] = {
		"diesel_l62": 350.0,
		"bread_wheat": 90.0,
		"flour_standard": 120.0,
	}
	city_stocks[City.OSTERWICK] = {
		"diesel_l62": 45.0,
		"bread_wheat": 30.0,
		"flour_standard": 55.0,
	}


# ── Генерация стакана 3×3 для каждого товара ──
func _update_all_orderbooks() -> void:
	for id in commodities:
		_update_orderbook(id)
	quotes_updated.emit()


func _update_orderbook(commodity_id: String) -> void:
	var commodity: Commodity = commodities[commodity_id]
	var book := OrderBook.new(commodity_id)
	
	var mid: float = commodity.price
	var tick_size: float = mid * 0.001  # минимальный шаг ~0.1%
	
	# Bids (покупатели) — от высокой цены к низкой
	for i in range(3):
		var price: float = mid - (i + 1) * tick_size * randf_range(0.5, 2.0)
		var vol: float = randf_range(10.0, 200.0)
		var n_orders: int = randi_range(1, 15)
		book.bids.append(OrderBookLevel.new(price, vol, n_orders))
	
	# Asks (продавцы) — от низкой цены к высокой
	for i in range(3):
		var price: float = mid + (i + 1) * tick_size * randf_range(0.5, 2.0)
		var vol: float = randf_range(10.0, 200.0)
		var n_orders: int = randi_range(1, 15)
		book.asks.append(OrderBookLevel.new(price, vol, n_orders))
	
	orderbooks[commodity_id] = book


# ── Тик обновления котировок (каждые 0.8 сек) ──
func _on_ticker_tick() -> void:
	for id in commodities:
		var c: Commodity = commodities[id]
		
		# Случайное изменение цены: ±0.5% (с трендом)
		var random_shift: float = randf_range(-0.005, 0.005)
		
		# Добавляем тренд (если спрос > предложение — цена растёт)
		var demand_bias: float = 0.0
		for city in city_demands:
			var demand: float = city_demands[city].get(c.id, 0.0)
			var stock: float = city_stocks[city].get(c.id, 0.0)
			if stock > 0:
				demand_bias += (demand / stock - 1.0) * 0.001
		
		var total_shift: float = random_shift + demand_bias
		var old_price: float = c.price
		c.price = old_price * (1.0 + total_shift)
		c.delta = ((c.price - c.base_price) / c.base_price) * 100.0
		c.trend = "up" if total_shift > 0.001 else ("down" if total_shift < -0.001 else "flat")
		c.volume_24h += randf_range(1.0, 50.0)
		c.spread = clampf(abs(old_price - c.price) / c.price * 100.0, 0.05, 2.0)
		
		_update_orderbook(id)
	
	quotes_updated.emit()


# ── Публичные методы доступа ──

## Получить товар по ID
func get_commodity(id: String) -> Commodity:
	return commodities.get(id)


## Получить все товары категории
func get_by_category(category: String) -> Array:
	var result: Array = []
	for id in commodities:
		if commodities[id].category == category:
			result.append(commodities[id])
	return result


## Получить все товары
func get_all_commodities() -> Dictionary:
	return commodities


## Получить стакан по товару
func get_orderbook(id: String) -> OrderBook:
	return orderbooks.get(id)


## Получить имя города
func get_city_name(city: int) -> String:
	if city >= 0 and city < city_names.size():
		return city_names[city]
	return "Неизвестно"


## Получить спрос города по товару
func get_city_demand(city: int, commodity_id: String) -> float:
	return city_demands.get(city, {}).get(commodity_id, 0.0)


## Получить остаток склада города
func get_city_stock(city: int, commodity_id: String) -> float:
	return city_stocks.get(city, {}).get(commodity_id, 0.0)


## Получить дефицит (спрос > остаток)
func is_in_deficit(city: int, commodity_id: String) -> bool:
	var demand: float = get_city_demand(city, commodity_id)
	var stock: float = get_city_stock(city, commodity_id)
	return demand > stock


## Торговый индекс города (среднее demand/stock по всем товарам)
func get_trade_index(city: int) -> float:
	var demands: Dictionary = city_demands.get(city, {})
	var stocks: Dictionary = city_stocks.get(city, {})
	var sum_ratio: float = 0.0
	var count: int = 0
	
	for id in demands:
		var stock: float = stocks.get(id, 0.0)
		if stock > 0:
			sum_ratio += demands[id] / stock
			count += 1
	
	return sum_ratio / count if count > 0 else 1.0


## Форматировать цену: 4800 → "4 800 CR"
static func format_price(price: float) -> String:
	var amount: int = roundf(price)
	var str: String = "%d" % amount
	# Вставить пробелы разрядов
	var result: Array[String] = []
	var i: int = str.length()
	while i > 0:
		var start: int = maxi(0, i - 3)
		result.push_front(str.substr(start, i - start))
		i = start
	return " ".join(result) + " CR"


## Форматировать дельту: 6.2 → "+6.2%", -3.1 → "-3.1%"
static func format_delta(delta: float) -> String:
	if delta >= 0:
		return "+%.1f%%" % delta
	return "%.1f%%" % delta


## Получить цвет дельты
static func get_delta_color(delta: float) -> Color:
	if delta > 0.1:
		return Color("#2DD4BF")  # profit
	elif delta < -0.1:
		return Color("#F2555A")  # loss
	return Color("#93A1B0")      # neutral
