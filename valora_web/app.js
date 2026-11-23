/**
 * ===================================================================
 * VALORA WEB - Complete Application Logic (Vanilla JS)
 * Identidade Visual Oficial: Warm Cream, Sage Green & Forest Green
 * 100% Offline-First (LocalStorage), Reativo e Sem Dependências
 * ===================================================================
 */

// --- 1. STATE & STORAGE MANAGEMENT ---
const STORAGE_KEYS = {
  FOOD_ITEMS: 'valora_food_items',
  SHOPPING_LIST: 'valora_shopping_list',
  ACTIVITIES: 'valora_activities',
  IS_PRO: 'valora_is_pro',
  THEME: 'valora_theme',
};

// Initial Demo Seed Data
const DEFAULT_FOODS = [
  {
    id: 'food-1',
    name: 'Morangos Frescos',
    category: 'fruits',
    quantity: 1,
    unit: 'un',
    storage: 'refrigerator',
    price: 12.50,
    expiryDate: new Date(Date.now() + 12 * 3600 * 1000).toISOString(), // 12 horas (Hoje!)
  },
  {
    id: 'food-2',
    name: 'Queijo Minas Frescal',
    category: 'dairy',
    quantity: 350,
    unit: 'g',
    storage: 'refrigerator',
    price: 18.90,
    expiryDate: new Date(Date.now() + 2 * 24 * 3600 * 1000).toISOString(), // 2 dias
  },
  {
    id: 'food-3',
    name: 'Leite Integral',
    category: 'dairy',
    quantity: 1,
    unit: 'L',
    storage: 'refrigerator',
    price: 5.49,
    expiryDate: new Date(Date.now() + 3 * 24 * 3600 * 1000).toISOString(), // 3 dias
  },
  {
    id: 'food-4',
    name: 'Pão Integral 12 Grãos',
    category: 'bakery',
    quantity: 1,
    unit: 'pct',
    storage: 'pantry',
    price: 11.20,
    expiryDate: new Date(Date.now() + 5 * 24 * 3600 * 1000).toISOString(), // 5 dias
  },
  {
    id: 'food-5',
    name: 'Filé de Tilápia',
    category: 'meatFish',
    quantity: 600,
    unit: 'g',
    storage: 'freezer',
    price: 34.00,
    expiryDate: new Date(Date.now() + 45 * 24 * 3600 * 1000).toISOString(), // 45 dias
  },
  {
    id: 'food-6',
    name: 'Arroz Integral Orgânico',
    category: 'pantryStaples',
    quantity: 1,
    unit: 'kg',
    storage: 'pantry',
    price: 9.80,
    expiryDate: new Date(Date.now() + 180 * 24 * 3600 * 1000).toISOString(), // 180 dias
  }
];

const DEFAULT_SHOPPING = [
  { id: 'shop-1', name: 'Azeite Extra Virgem', category: 'pantryStaples', quantity: 1, unit: 'un', isChecked: false },
  { id: 'shop-2', name: 'Ovos Caipiras', category: 'dairy', quantity: 12, unit: 'un', isChecked: true },
  { id: 'shop-3', name: 'Iogurte Natural', category: 'dairy', quantity: 2, unit: 'un', isChecked: false },
];

const DEFAULT_ACTIVITIES = [
  { id: 'act-1', name: 'Iogurte Grego', category: 'dairy', type: 'consumed', quantity: 0.35, price: 8.50, timestamp: new Date(Date.now() - 3 * 24 * 3600 * 1000).toISOString() },
  { id: 'act-2', name: 'Peito de Frango', category: 'meatFish', type: 'consumed', quantity: 0.8, price: 21.00, timestamp: new Date(Date.now() - 5 * 24 * 3600 * 1000).toISOString() },
  { id: 'act-3', name: 'Espinafre Orgânico', category: 'vegetables', type: 'consumed', quantity: 0.4, price: 6.00, timestamp: new Date(Date.now() - 7 * 24 * 3600 * 1000).toISOString() },
];

// App Global State
let state = {
  foods: [],
  shopping: [],
  activities: [],
  isPro: true, // Default to PRO unlocked so user tests all features seamlessly!
  currentTab: 'pantry',
  searchQuery: '',
  selectedCategory: null,
  selectedStorage: null,
  sortOption: 'expirySoonest',
  selectedFoodForModal: null,
};

// Category config with emojis and labels
const CATEGORY_MAP = {
  fruits: { label: 'Frutas', emoji: '🍎', color: '#E76F51' },
  vegetables: { label: 'Verduras', emoji: '🥦', color: '#2A9D8F' },
  dairy: { label: 'Laticínios', emoji: '🧀', color: '#E9C46A' },
  meatFish: { label: 'Carnes & Peixes', emoji: '🥩', color: '#D94848' },
  bakery: { label: 'Padaria', emoji: '🍞', color: '#D4A373' },
  pantryStaples: { label: 'Despensa', emoji: '🥫', color: '#749F81' },
  frozen: { label: 'Congelados', emoji: '🧊', color: '#457B9D' },
  drinks: { label: 'Bebidas', emoji: '🧃', color: '#8338EC' },
  other: { label: 'Outros', emoji: '📦', color: '#588157' }
};

const STORAGE_MAP = {
  refrigerator: { label: 'Geladeira', icon: 'kitchen', emoji: '🧊' },
  freezer: { label: 'Congelador', icon: 'ac_unit', emoji: '❄️' },
  pantry: { label: 'Despensa', icon: 'shelves', emoji: '🧺' },
  other: { label: 'Outro', icon: 'place', emoji: '📦' }
};

// Eco Footprint Factors
const WATER_FOOTPRINT = {
  meatFish: 15400,
  dairy: 3200,
  pantryStaples: 1800,
  bakery: 1608,
  frozen: 2500,
  drinks: 800,
  fruits: 962,
  vegetables: 322,
  other: 1200
};

const CARBON_FOOTPRINT = {
  meatFish: 27.0,
  dairy: 8.5,
  frozen: 4.2,
  pantryStaples: 2.7,
  bakery: 1.6,
  drinks: 1.2,
  fruits: 1.1,
  vegetables: 2.0,
  other: 2.0
};

// --- 2. INITIALIZATION ---
function initApp() {
  loadFromStorage();
  applySavedTheme();
  setupEventListeners();
  renderApp();
}

function loadFromStorage() {
  const savedFoods = localStorage.getItem(STORAGE_KEYS.FOOD_ITEMS);
  state.foods = savedFoods ? JSON.parse(savedFoods) : DEFAULT_FOODS;

  const savedShopping = localStorage.getItem(STORAGE_KEYS.SHOPPING_LIST);
  state.shopping = savedShopping ? JSON.parse(savedShopping) : DEFAULT_SHOPPING;

  const savedActivities = localStorage.getItem(STORAGE_KEYS.ACTIVITIES);
  state.activities = savedActivities ? JSON.parse(savedActivities) : DEFAULT_ACTIVITIES;

  const savedPro = localStorage.getItem(STORAGE_KEYS.IS_PRO);
  state.isPro = savedPro !== null ? JSON.parse(savedPro) : true;
}

function saveFoods() {
  localStorage.setItem(STORAGE_KEYS.FOOD_ITEMS, JSON.stringify(state.foods));
}

function saveShopping() {
  localStorage.setItem(STORAGE_KEYS.SHOPPING_LIST, JSON.stringify(state.shopping));
  updateShoppingBadge();
}

function saveActivities() {
  localStorage.setItem(STORAGE_KEYS.ACTIVITIES, JSON.stringify(state.activities));
}

function saveProStatus(val) {
  state.isPro = val;
  localStorage.setItem(STORAGE_KEYS.IS_PRO, JSON.stringify(val));
  updateProUi();
  renderPantry();
  renderImpact();
}

// --- 3. THEME MANAGEMENT (Claro Padrão, Escuro Opcional) ---
function applySavedTheme() {
  const theme = localStorage.getItem(STORAGE_KEYS.THEME) || 'light';
  if (theme === 'dark') {
    document.body.classList.add('theme-dark');
  } else {
    document.body.classList.remove('theme-dark');
  }
}

function toggleTheme() {
  const isDark = document.body.classList.toggle('theme-dark');
  localStorage.setItem(STORAGE_KEYS.THEME, isDark ? 'dark' : 'light');
  showToast(isDark ? '🌙 Tema Escuro ativado' : '☀️ Tema Claro ativado');
}

// --- 4. ACCENT-INSENSITIVE SEARCH & NORMALIZATION (FEATURE 5 [FREE]) ---
function normalizeText(text) {
  if (!text) return '';
  return text.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim();
}

function matchesSearch(text, query) {
  if (!query) return true;
  return normalizeText(text).includes(normalizeText(query));
}

// --- 5. SHELF-LIFE & DAYS REMAINING CALCULATIONS (FEATURE 4 & 10) ---
function getExpiryInfo(dateStr) {
  const target = new Date(dateStr);
  const now = new Date();
  
  const diffMs = target.getTime() - now.getTime();
  const diffHours = diffMs / (1000 * 3600);
  const diffDays = Math.ceil(diffMs / (1000 * 3600 * 24));

  let statusClass = 'safe';
  let badgeText = '';
  let paceLabel = 'Ritmo tranquilo';

  if (diffHours <= 0) {
    statusClass = 'expired';
    badgeText = 'Venceu';
    paceLabel = 'Vencido';
  } else if (diffHours <= 24) {
    statusClass = 'today';
    badgeText = 'Vence hoje';
    paceLabel = 'Urgente';
  } else if (diffDays <= 3) {
    statusClass = 'urgent';
    badgeText = `${diffDays} dias`;
    paceLabel = 'Prioridade';
  } else if (diffDays <= 7) {
    statusClass = 'urgent';
    badgeText = `${diffDays} dias`;
    paceLabel = 'Consumir logo';
  } else {
    statusClass = 'safe';
    badgeText = `${diffDays} dias`;
    paceLabel = 'Ritmo tranquilo';
  }

  const isUrgentForRescue = state.isPro && diffHours > 0 && diffHours <= 24;

  return {
    diffDays,
    diffHours,
    statusClass,
    badgeText,
    paceLabel,
    isUrgentForRescue
  };
}

// --- 6. RENDER PANTRY VIEW ---
function renderPantry() {
  const listEl = document.getElementById('pantry-food-list');
  const countEl = document.getElementById('pantry-total-count');
  const emptyEl = document.getElementById('pantry-empty-state');
  
  if (!listEl) return;

  // Filter items
  let filtered = state.foods.filter(item => {
    // Search
    const matchesName = matchesSearch(item.name, state.searchQuery);
    const catName = CATEGORY_MAP[item.category]?.label || '';
    const matchesCat = matchesSearch(catName, state.searchQuery);
    if (!matchesName && !matchesCat) return false;

    // Category filter
    if (state.selectedCategory && item.category !== state.selectedCategory) return false;

    // Storage filter (FEATURE 3 [FREE])
    if (state.selectedStorage && item.storage !== state.selectedStorage) return false;

    return true;
  });

  // Sort items
  filtered.sort((a, b) => {
    if (state.sortOption === 'expirySoonest') {
      return new Date(a.expiryDate).getTime() - new Date(b.expiryDate).getTime();
    } else if (state.sortOption === 'expiryLatest') {
      return new Date(b.expiryDate).getTime() - new Date(a.expiryDate).getTime();
    } else if (state.sortOption === 'nameAZ') {
      return a.name.localeCompare(b.name);
    }
    return 0;
  });

  countEl.textContent = `${state.foods.length} alimentos organizados`;

  if (filtered.length === 0) {
    listEl.innerHTML = '';
    emptyEl.style.display = 'block';
    return;
  }

  emptyEl.style.display = 'none';
  listEl.innerHTML = filtered.map(item => {
    const cat = CATEGORY_MAP[item.category] || CATEGORY_MAP.other;
    const stor = STORAGE_MAP[item.storage] || STORAGE_MAP.other;
    const exp = getExpiryInfo(item.expiryDate);

    return `
      <div class="food-card" onclick="openFoodDetailsModal('${item.id}')">
        <div class="food-category-icon">
          ${cat.emoji}
        </div>
        <div class="food-info">
          <div class="food-name-row">
            <span class="food-name">${escapeHtml(item.name)}</span>
            ${exp.isUrgentForRescue ? `<span class="rescue-badge" title="Alerta PRO: Salvar nas próximas horas">🚨 Resgatar</span>` : ''}
          </div>
          <div class="food-meta-row">
            <span>${item.quantity} ${item.unit}</span>
            <span>•</span>
            <span class="food-storage-badge">${stor.emoji} ${stor.label}</span>
          </div>
        </div>
        <div class="food-status-wrapper">
          <span class="expiry-badge ${exp.statusClass}">${exp.badgeText}</span>
          <span class="pace-pill">${exp.paceLabel}</span>
        </div>
      </div>
    `;
  }).join('');
}

// --- 7. FEATURE 2 [FREE]: QUICK FOOD PRESETS WITH AUTO EXPIRY ---
const QUICK_PRESETS = [
  { name: 'Morangos Frescos', days: 5, cat: 'fruits', storage: 'refrigerator', unit: 'un', qty: 1, price: 12.0 },
  { name: 'Leite Integral', days: 5, cat: 'dairy', storage: 'refrigerator', unit: 'L', qty: 1, price: 5.50 },
  { name: 'Ovos da Granja', days: 21, cat: 'dairy', storage: 'refrigerator', unit: 'un', qty: 12, price: 14.0 },
  { name: 'Pão de Forma', days: 7, cat: 'bakery', storage: 'pantry', unit: 'pct', qty: 1, price: 9.90 },
  { name: 'Iogurte Natural', days: 12, cat: 'dairy', storage: 'refrigerator', unit: 'un', qty: 2, price: 7.20 },
  { name: 'Queijo Minas', days: 10, cat: 'dairy', storage: 'refrigerator', unit: 'g', qty: 400, price: 19.50 },
  { name: 'Peito de Frango', days: 3, cat: 'meatFish', storage: 'refrigerator', unit: 'kg', qty: 1, price: 23.0 },
  { name: 'Espinafre Fresco', days: 4, cat: 'vegetables', storage: 'refrigerator', unit: 'un', qty: 1, price: 5.0 }
];

function renderPresets() {
  const container = document.getElementById('presets-carousel');
  if (!container) return;

  container.innerHTML = QUICK_PRESETS.map(p => `
    <button class="preset-chip" onclick="applyPreset('${p.name}')">
      + ${p.name} (${p.days}d)
    </button>
  `).join('');
}

function applyPreset(presetName) {
  const p = QUICK_PRESETS.find(x => x.name === presetName);
  if (!p) return;

  const expiry = new Date();
  expiry.setDate(expiry.getDate() + p.days);
  const dateFormatted = expiry.toISOString().split('T')[0];

  openAddFoodModal({
    name: p.name,
    category: p.cat,
    storage: p.storage,
    unit: p.unit,
    quantity: p.qty,
    price: p.price,
    expiryDate: dateFormatted
  });
}

// --- 8. FEATURE 1 [FREE]: SMART SHOPPING LIST ---
function renderShoppingList() {
  const listEl = document.getElementById('shopping-items-list');
  const countEl = document.getElementById('shopping-header-count');
  if (!listEl) return;

  const unchecked = state.shopping.filter(i => !i.isChecked).length;
  countEl.textContent = `${unchecked} itens pendentes`;

  if (state.shopping.length === 0) {
    listEl.innerHTML = `
      <div class="empty-state">
        <div class="empty-icon">🛒</div>
        <div class="empty-title">Lista de Compras Vazia</div>
        <p class="empty-text">Adicione o que está faltando na sua despensa ou importe itens com 1 clique.</p>
      </div>
    `;
    return;
  }

  listEl.innerHTML = state.shopping.map(item => `
    <div class="shopping-item-tile ${item.isChecked ? 'checked' : ''}">
      <div class="shopping-checkbox ${item.isChecked ? 'checked' : ''}" onclick="toggleShoppingItem('${item.id}')">
        ${item.isChecked ? '✓' : ''}
      </div>
      <span class="shopping-name" onclick="toggleShoppingItem('${item.id}')">${escapeHtml(item.name)}</span>
      <span class="shopping-qty">${item.quantity} ${item.unit}</span>
      <button class="item-delete-btn" onclick="deleteShoppingItem('${item.id}')" title="Excluir">✕</button>
    </div>
  `).join('');
}

function addShoppingItem() {
  const input = document.getElementById('new-shopping-input');
  const name = input?.value?.trim();
  if (!name) return;

  const newItem = {
    id: 'shop-' + Date.now(),
    name: name,
    category: 'pantryStaples',
    quantity: 1,
    unit: 'un',
    isChecked: false
  };

  state.shopping.unshift(newItem);
  saveShopping();
  input.value = '';
  renderShoppingList();
  showToast(`Item "${name}" adicionado à lista!`);
}

function toggleShoppingItem(id) {
  const item = state.shopping.find(i => i.id === id);
  if (item) {
    item.isChecked = !item.isChecked;
    saveShopping();
    renderShoppingList();
  }
}

function deleteShoppingItem(id) {
  state.shopping = state.shopping.filter(i => i.id !== id);
  saveShopping();
  renderShoppingList();
}

function clearCompletedShopping() {
  const prevCount = state.shopping.length;
  state.shopping = state.shopping.filter(i => !i.isChecked);
  saveShopping();
  renderShoppingList();
  showToast(`Itens concluídos removidos.`);
}

function updateShoppingBadge() {
  const badge = document.getElementById('header-shopping-badge');
  if (!badge) return;
  const count = state.shopping.filter(i => !i.isChecked).length;
  if (count > 0) {
    badge.textContent = count;
    badge.style.display = 'inline-block';
  } else {
    badge.style.display = 'none';
  }
}

// Bridge: Add Food from pantry details modal directly to shopping list
function addPantryFoodToShoppingList(foodId) {
  const food = state.foods.find(f => f.id === foodId);
  if (!food) return;

  const existing = state.shopping.find(s => !s.isChecked && normalizeText(s.name) === normalizeText(food.name));
  if (existing) {
    existing.quantity += food.quantity;
  } else {
    state.shopping.unshift({
      id: 'shop-' + Date.now(),
      name: food.name,
      category: food.category,
      quantity: food.quantity,
      unit: food.unit,
      isChecked: false
    });
  }

  saveShopping();
  closeModal('food-details-modal');
  showToast(`"${food.name}" adicionado à Lista de Compras!`);
}

// --- 9. FEATURE 6 [PREMIUM]: ZERO-WASTE RECIPE GENERATOR ---
function generateRecipeSuggestions() {
  // Finds items expiring in next 4 days
  const now = new Date();
  const expiring = state.foods.filter(f => {
    const diffDays = (new Date(f.expiryDate).getTime() - now.getTime()) / (1000 * 3600 * 24);
    return diffDays <= 4;
  });

  const names = expiring.map(e => e.name);
  if (names.length === 0) {
    names.push('Legumes da gaveta', 'Ovos', 'Queijo');
  }

  const recipes = [
    {
      title: 'Omelete Rápido Nutritivo',
      prepTime: '10 min',
      difficulty: 'Fácil',
      desc: 'Ideal para aproveitar rapidamente legumes, queijos e proteínas antes que vençam.',
      ingredients: names.slice(0, 3),
      steps: [
        'Bata 2 a 3 ovos com uma pitada de sal e pimenta.',
        `Pique ${names.slice(0, 2).join(' e ')} em pedaços pequenos e refogue levemente no azeite.`,
        'Despeje os ovos batidos sobre os ingredientes e doure dos dois lados por 3 minutos.'
      ]
    },
    {
      title: 'Torta Salgada de Liquidificador',
      prepTime: '35 min',
      difficulty: 'Médio',
      desc: 'A receita mais famosa para salvar múltiplos itens da despensa de uma só vez.',
      ingredients: names.slice(0, 4),
      steps: [
        'Bata no liquidificador: 3 ovos, 2 xícaras de leite, 1/2 xícara de óleo e 2 xícaras de farinha com fermento.',
        `Pique ${names.join(', ')} e tempere a gosto para o recheio anti-desperdício.`,
        'Despeje metade da massa em assadeira untada, cubra com o recheio e asse a 180°C por 30 minutos.'
      ]
    },
    {
      title: 'Sopa Creme Reconfortante',
      prepTime: '20 min',
      difficulty: 'Fácil',
      desc: 'Perfeita para legumes e hortaliças que estão perto da maturação máxima.',
      ingredients: names.slice(0, 3),
      steps: [
        `Cozinhe ${names.slice(0, 3).join(', ')} em caldo temperado com cebola, alho e azeite.`,
        'Bata com mixer ou liquidificador até obter consistência cremosa aveludada.',
        'Finalize com queijo ralado e torradas de pão da despensa.'
      ]
    }
  ];

  return recipes;
}

function openRecipesModal() {
  if (!state.isPro) {
    openPaywallModal();
    return;
  }

  const listEl = document.getElementById('recipes-modal-list');
  const recipes = generateRecipeSuggestions();

  listEl.innerHTML = recipes.map(r => `
    <div class="recipe-card">
      <div class="recipe-header">
        <span class="recipe-title">${r.title}</span>
        <span class="recipe-pill">${r.prepTime} • ${r.difficulty}</span>
      </div>
      <p style="font-size: 12px; color: var(--text-muted); margin-bottom: 8px;">${r.desc}</p>
      <div style="font-size: 11px; font-weight: 700; color: var(--forest-green); margin-bottom: 4px;">
        Aproveita: ${r.ingredients.join(', ')}
      </div>
      <ol class="recipe-steps">
        ${r.steps.map(s => `<li>${s}</li>`).join('')}
      </ol>
    </div>
  `).join('');

  openModal('recipes-modal');
}

// --- 10. FEATURE 8 [PREMIUM]: BATCH FREEZING SHELF-LIFE EXTENDER (+90d) ---
function freezeItemToExtendShelfLife(foodId) {
  if (!state.isPro) {
    openPaywallModal();
    return;
  }

  const food = state.foods.find(f => f.id === foodId);
  if (!food) return;

  const currentExpiry = new Date(food.expiryDate);
  currentExpiry.setDate(currentExpiry.getDate() + 90);

  food.expiryDate = currentExpiry.toISOString();
  food.storage = 'freezer';

  saveFoods();
  closeModal('food-details-modal');
  renderPantry();
  renderExpiryCenter();
  showToast(`❄️ "${food.name}" movido para o congelador! Validade prorrogada em +90 dias.`);
}

// --- 11. FEATURE 7 & 9 [PREMIUM]: FINANCIAL ROI & SCIENTIFIC ECO-FOOTPRINT ---
function renderImpact() {
  // Calculate total consumed / saved
  let totalSavedMoney = 0;
  let totalWeightKg = 0;
  let totalWaterLiters = 0;
  let totalCo2Kg = 0;

  state.activities.forEach(act => {
    if (act.type === 'consumed') {
      totalSavedMoney += act.price || 15.0;
      const weight = act.quantity || 0.5;
      totalWeightKg += weight;
      totalWaterLiters += weight * (WATER_FOOTPRINT[act.category] || 1200);
      totalCo2Kg += weight * (CARBON_FOOTPRINT[act.category] || 2.0);
    }
  });

  // ROI calculations (FEATURE 7 [PREMIUM])
  const monthlyProjected = totalSavedMoney > 0 ? totalSavedMoney * 3 : 142.50;
  const annualProjected = monthlyProjected * 12;
  const proAnnualCost = 89.90;
  const roiMultiplier = (annualProjected / proAnnualCost).toFixed(1);

  // Update DOM elements
  document.getElementById('impact-money-saved').textContent = `R$ ${totalSavedMoney.toFixed(2)}`;
  document.getElementById('impact-weight-saved').textContent = `${totalWeightKg.toFixed(1)} kg`;
  
  // Format water (m3 or Liters)
  const formattedWater = totalWaterLiters >= 1000 
    ? `${(totalWaterLiters / 1000).toFixed(1)} m³` 
    : `${Math.round(totalWaterLiters)} L`;
  document.getElementById('impact-water-saved').textContent = formattedWater;
  document.getElementById('impact-co2-saved').textContent = `${totalCo2Kg.toFixed(1)} kg`;

  // ROI Card
  document.getElementById('roi-annual-amount').textContent = `R$ ${annualProjected.toFixed(2)} / ano`;
  document.getElementById('roi-multiplier-tag').textContent = `${roiMultiplier}x de Retorno`;
}

// Feature 7 [Premium]: Clipboard Executive Report Export
function copyExecutiveReportToClipboard() {
  const money = document.getElementById('impact-money-saved').textContent;
  const annual = document.getElementById('roi-annual-amount').textContent;
  const weight = document.getElementById('impact-weight-saved').textContent;
  const water = document.getElementById('impact-water-saved').textContent;
  const co2 = document.getElementById('impact-co2-saved').textContent;

  const report = `
📊 VALORA - Relatório Executivo de Economia & Sustentabilidade Doméstica
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💰 Economia Mensal Realizada: ${money}
📈 Economia Projetada Anual: ${annual}
🥦 Alimentos Salvos do Desperdício: ${weight}
💧 Pegada Hídrica Preservada: ${water}
🌱 Emissões de CO₂ Evitadas: ${co2}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Compromisso com Gestão Inteligente de Despensa e Desperdício Zero.
Gerado com orgulho pelo Valora Web.
`.trim();

  navigator.clipboard.writeText(report).then(() => {
    showToast('📋 Relatório copiado para a Área de Transferência!');
  }).catch(() => {
    showToast('Falha ao copiar. Permissão negada pelo navegador.');
  });
}

// --- 12. EXPIRY TIMELINE VIEW ---
function renderExpiryCenter() {
  const listEl = document.getElementById('expiry-timeline-list');
  if (!listEl) return;

  const sorted = [...state.foods].sort((a, b) => new Date(a.expiryDate) - new Date(b.expiryDate));

  if (sorted.length === 0) {
    listEl.innerHTML = `<p class="empty-text">Nenhum alimento cadastrado na despensa.</p>`;
    return;
  }

  listEl.innerHTML = sorted.map(item => {
    const exp = getExpiryInfo(item.expiryDate);
    const cat = CATEGORY_MAP[item.category] || CATEGORY_MAP.other;

    return `
      <div class="food-card" onclick="openFoodDetailsModal('${item.id}')">
        <div class="food-category-icon">${cat.emoji}</div>
        <div class="food-info">
          <div class="food-name-row">
            <span class="food-name">${escapeHtml(item.name)}</span>
            ${exp.isUrgentForRescue ? `<span class="rescue-badge">🚨 Resgatar</span>` : ''}
          </div>
          <div class="food-meta-row">
            <span>Validade: ${new Date(item.expiryDate).toLocaleDateString('pt-BR')}</span>
          </div>
        </div>
        <div class="food-status-wrapper">
          <span class="expiry-badge ${exp.statusClass}">${exp.badgeText}</span>
          <span class="pace-pill">${exp.paceLabel}</span>
        </div>
      </div>
    `;
  }).join('');
}

// --- 13. MODALS LOGIC ---
function openModal(id) {
  const m = document.getElementById(id);
  if (m) m.classList.add('active');
}

function closeModal(id) {
  const m = document.getElementById(id);
  if (m) m.classList.remove('active');
}

function openAddFoodModal(prefill = {}) {
  const nameInput = document.getElementById('food-input-name');
  const catInput = document.getElementById('food-input-category');
  const storInput = document.getElementById('food-input-storage');
  const unitInput = document.getElementById('food-input-unit');
  const qtyInput = document.getElementById('food-input-qty');
  const priceInput = document.getElementById('food-input-price');
  const dateInput = document.getElementById('food-input-expiry');

  nameInput.value = prefill.name || '';
  catInput.value = prefill.category || 'pantryStaples';
  storInput.value = prefill.storage || 'refrigerator';
  unitInput.value = prefill.unit || 'un';
  qtyInput.value = prefill.quantity || 1;
  priceInput.value = prefill.price || '';

  if (prefill.expiryDate) {
    dateInput.value = prefill.expiryDate;
  } else {
    // Default 7 days from now
    const d = new Date();
    d.setDate(d.getDate() + 7);
    dateInput.value = d.toISOString().split('T')[0];
  }

  openModal('add-food-modal');
}

function saveNewFood(e) {
  if (e) e.preventDefault();

  const name = document.getElementById('food-input-name').value.trim();
  const cat = document.getElementById('food-input-category').value;
  const stor = document.getElementById('food-input-storage').value;
  const unit = document.getElementById('food-input-unit').value;
  const qty = parseFloat(document.getElementById('food-input-qty').value) || 1;
  const price = parseFloat(document.getElementById('food-input-price').value) || 0;
  const dateStr = document.getElementById('food-input-expiry').value;

  if (!name) {
    showToast('Informe o nome do alimento');
    return;
  }

  const newFood = {
    id: 'food-' + Date.now(),
    name,
    category: cat,
    storage: stor,
    unit,
    quantity: qty,
    price,
    expiryDate: new Date(dateStr + 'T12:00:00').toISOString()
  };

  state.foods.unshift(newFood);
  saveFoods();
  closeModal('add-food-modal');
  renderPantry();
  renderExpiryCenter();
  showToast(`"${name}" adicionado à despensa com sucesso!`);
}

function openFoodDetailsModal(id) {
  const food = state.foods.find(f => f.id === id);
  if (!food) return;

  state.selectedFoodForModal = food;
  const cat = CATEGORY_MAP[food.category] || CATEGORY_MAP.other;
  const stor = STORAGE_MAP[food.storage] || STORAGE_MAP.other;
  const exp = getExpiryInfo(food.expiryDate);

  document.getElementById('detail-food-emoji').textContent = cat.emoji;
  document.getElementById('detail-food-name').textContent = food.name;
  document.getElementById('detail-food-qty').textContent = `${food.quantity} ${food.unit}`;
  document.getElementById('detail-food-storage').textContent = `${stor.emoji} ${stor.label}`;
  document.getElementById('detail-food-expiry').textContent = new Date(food.expiryDate).toLocaleDateString('pt-BR');
  document.getElementById('detail-food-badge').textContent = exp.badgeText;
  document.getElementById('detail-food-badge').className = `expiry-badge ${exp.statusClass}`;

  // Configure action buttons
  document.getElementById('detail-btn-freeze').onclick = () => freezeItemToExtendShelfLife(food.id);
  document.getElementById('detail-btn-shopping').onclick = () => addPantryFoodToShoppingList(food.id);
  document.getElementById('detail-btn-consume').onclick = () => recordFoodAction(food.id, 'consumed');
  document.getElementById('detail-btn-discard').onclick = () => recordFoodAction(food.id, 'discarded');
  document.getElementById('detail-btn-delete').onclick = () => deleteFoodPermanently(food.id);

  openModal('food-details-modal');
}

function recordFoodAction(foodId, actionType) {
  const food = state.foods.find(f => f.id === foodId);
  if (!food) return;

  state.activities.unshift({
    id: 'act-' + Date.now(),
    name: food.name,
    category: food.category,
    type: actionType,
    quantity: food.unit === 'kg' ? food.quantity : (food.quantity * 0.35),
    price: food.price || 12.0,
    timestamp: new Date().toISOString()
  });

  state.foods = state.foods.filter(f => f.id !== foodId);
  saveFoods();
  saveActivities();
  closeModal('food-details-modal');
  renderPantry();
  renderExpiryCenter();
  renderImpact();

  if (actionType === 'consumed') {
    showToast(`Parabéns! "${food.name}" consumido a tempo e salvo! 🎉`);
  } else {
    showToast(`"${food.name}" descartado.`);
  }
}

function deleteFoodPermanently(foodId) {
  state.foods = state.foods.filter(f => f.id !== foodId);
  saveFoods();
  closeModal('food-details-modal');
  renderPantry();
  renderExpiryCenter();
  showToast('Alimento removido da despensa.');
}

// --- 14. VALORA PRO PAYWALL MODAL ---
function openPaywallModal() {
  openModal('paywall-modal');
}

function activateProTrial() {
  saveProStatus(true);
  closeModal('paywall-modal');
  showToast('⭐ Valora PRO ativado com sucesso! Aproveite todos os recursos.');
}

function toggleProFromSettings() {
  const next = !state.isPro;
  saveProStatus(next);
  showToast(next ? '⭐ Modo Valora PRO Ativado!' : 'Modo Gratuito Ativado.');
}

function updateProUi() {
  const badge = document.getElementById('brand-pro-badge');
  const settingsStatus = document.getElementById('settings-pro-status');
  if (badge) badge.style.display = state.isPro ? 'inline-block' : 'none';
  if (settingsStatus) settingsStatus.textContent = state.isPro ? 'Assinatura Ativa (PRO)' : 'Plano Gratuito';
}

// --- 15. BACKUP & DATA MANAGEMENT ---
function exportDataBackup() {
  const data = {
    app: 'Valora Web',
    version: '1.0.0',
    exportDate: new Date().toISOString(),
    foods: state.foods,
    shopping: state.shopping,
    activities: state.activities,
    isPro: state.isPro
  };

  const jsonStr = 'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(data, null, 2));
  const dlAnchor = document.createElement('a');
  dlAnchor.setAttribute('href', jsonStr);
  dlAnchor.setAttribute('download', `valora_backup_${new Date().toISOString().split('T')[0]}.json`);
  dlAnchor.click();
  showToast('📦 Backup exportado com sucesso!');
}

function resetToDemoData() {
  if (confirm('Deseja restaurar os dados de demonstração originais?')) {
    state.foods = DEFAULT_FOODS;
    state.shopping = DEFAULT_SHOPPING;
    state.activities = DEFAULT_ACTIVITIES;
    saveFoods();
    saveShopping();
    saveActivities();
    renderApp();
    showToast('Dados restaurados com sucesso.');
  }
}

// --- 16. TOAST FEEDBACK ---
function showToast(message) {
  const container = document.getElementById('toast-container');
  if (!container) return;

  const toast = document.createElement('div');
  toast.className = 'toast';
  toast.textContent = message;
  container.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transition = 'opacity 200ms ease';
    setTimeout(() => toast.remove(), 200);
  }, 2600);
}

function escapeHtml(str) {
  return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

// --- 17. NAVIGATION & TAB SWITCHING ---
function switchTab(tabId) {
  state.currentTab = tabId;

  document.querySelectorAll('.view-panel').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.nav-tab').forEach(t => t.classList.remove('active'));

  const view = document.getElementById(`view-${tabId}`);
  const navTab = document.querySelector(`.nav-tab[data-tab="${tabId}"]`);

  if (view) view.classList.add('active');
  if (navTab) navTab.classList.add('active');

  // Trigger relevant view renderers
  if (tabId === 'pantry') renderPantry();
  if (tabId === 'expiry') renderExpiryCenter();
  if (tabId === 'impact') renderImpact();
  if (tabId === 'shopping') renderShoppingList();
}

// --- 18. EVENT LISTENERS SETUP ---
function setupEventListeners() {
  // Tab switching
  document.querySelectorAll('.nav-tab').forEach(tab => {
    tab.addEventListener('click', (e) => {
      e.preventDefault();
      const target = tab.getAttribute('data-tab');
      switchTab(target);
    });
  });

  // Search input
  const searchInput = document.getElementById('pantry-search-input');
  const clearBtn = document.getElementById('pantry-search-clear');
  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      state.searchQuery = e.target.value;
      if (clearBtn) clearBtn.classList.toggle('visible', state.searchQuery.length > 0);
      renderPantry();
    });
  }
  if (clearBtn) {
    clearBtn.addEventListener('click', () => {
      searchInput.value = '';
      state.searchQuery = '';
      clearBtn.classList.remove('visible');
      renderPantry();
    });
  }

  // Sort dropdown
  const sortSelect = document.getElementById('pantry-sort-select');
  if (sortSelect) {
    sortSelect.addEventListener('change', (e) => {
      state.sortOption = e.target.value;
      renderPantry();
    });
  }

  // Category filter chips
  document.querySelectorAll('.cat-filter-chip').forEach(chip => {
    chip.addEventListener('click', () => {
      const cat = chip.getAttribute('data-category');
      if (state.selectedCategory === cat) {
        state.selectedCategory = null;
        chip.classList.remove('active');
      } else {
        document.querySelectorAll('.cat-filter-chip').forEach(c => c.classList.remove('active'));
        state.selectedCategory = cat;
        chip.classList.add('active');
      }
      renderPantry();
    });
  });

  // Storage location filter chips (FEATURE 3 [FREE])
  document.querySelectorAll('.storage-filter-chip').forEach(chip => {
    chip.addEventListener('click', () => {
      const stor = chip.getAttribute('data-storage');
      if (state.selectedStorage === stor) {
        state.selectedStorage = null;
        chip.classList.remove('active');
      } else {
        document.querySelectorAll('.storage-filter-chip').forEach(c => c.classList.remove('active'));
        state.selectedStorage = stor;
        chip.classList.add('active');
      }
      renderPantry();
    });
  });

  // Modal close buttons
  document.querySelectorAll('.modal-close, .modal-overlay').forEach(el => {
    el.addEventListener('click', (e) => {
      if (e.target === el) {
        el.closest('.modal-overlay').classList.remove('active');
      }
    });
  });

  // Keyboard accessibility
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      document.querySelectorAll('.modal-overlay.active').forEach(m => m.classList.remove('active'));
    }
  });
}

function renderApp() {
  updateProUi();
  updateShoppingBadge();
  renderPresets();
  renderPantry();
  renderShoppingList();
  renderExpiryCenter();
  renderImpact();
}

// Start app upon DOM load
document.addEventListener('DOMContentLoaded', initApp);
