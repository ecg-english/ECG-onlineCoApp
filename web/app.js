// API設定
// TODO: Renderにデプロイ後、実際のURLに変更してください
const API_BASE_URL = 'http://localhost:3000/api';

// 状態管理
let currentUser = null;
let authToken = localStorage.getItem('authToken');

// 初期化
document.addEventListener('DOMContentLoaded', () => {
    if (authToken) {
        verifyToken();
    }
});

// API呼び出しヘルパー
async function apiCall(endpoint, method = 'GET', body = null) {
    const headers = {
        'Content-Type': 'application/json'
    };
    
    if (authToken) {
        headers['Authorization'] = `Bearer ${authToken}`;
    }
    
    const options = {
        method,
        headers
    };
    
    if (body) {
        options.body = JSON.stringify(body);
    }
    
    const response = await fetch(`${API_BASE_URL}${endpoint}`, options);
    
    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return await response.json();
}

// 認証
async function login(event) {
    event.preventDefault();
    
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;
    const errorEl = document.getElementById('loginError');
    
    try {
        const data = await apiCall('/auth/login', 'POST', { email, password });
        authToken = data.token;
        localStorage.setItem('authToken', authToken);
        currentUser = data.user;
        showMainContent();
    } catch (error) {
        errorEl.textContent = 'ログインに失敗しました';
        errorEl.style.display = 'block';
    }
}

async function signup(event) {
    event.preventDefault();
    
    const username = document.getElementById('signupUsername').value;
    const email = document.getElementById('signupEmail').value;
    const password = document.getElementById('signupPassword').value;
    const confirmPassword = document.getElementById('signupConfirmPassword').value;
    const errorEl = document.getElementById('signupError');
    
    if (password !== confirmPassword) {
        errorEl.textContent = 'パスワードが一致しません';
        errorEl.style.display = 'block';
        return;
    }
    
    try {
        const data = await apiCall('/auth/signup', 'POST', { email, password, username });
        authToken = data.token;
        localStorage.setItem('authToken', authToken);
        currentUser = data.user;
        showMainContent();
    } catch (error) {
        errorEl.textContent = 'アカウント作成に失敗しました';
        errorEl.style.display = 'block';
    }
}

async function verifyToken() {
    try {
        const data = await apiCall('/auth/me');
        currentUser = data.user;
        showMainContent();
    } catch (error) {
        logout();
    }
}

function logout() {
    authToken = null;
    currentUser = null;
    localStorage.removeItem('authToken');
    showLogin();
}

// 画面表示切り替え
function showLogin() {
    document.getElementById('loginView').style.display = 'flex';
    document.getElementById('signupView').style.display = 'none';
    document.getElementById('mainContent').style.display = 'none';
    document.getElementById('header').style.display = 'none';
}

function showSignup() {
    document.getElementById('loginView').style.display = 'none';
    document.getElementById('signupView').style.display = 'flex';
    document.getElementById('mainContent').style.display = 'none';
    document.getElementById('header').style.display = 'none';
}

function showMainContent() {
    document.getElementById('loginView').style.display = 'none';
    document.getElementById('signupView').style.display = 'none';
    document.getElementById('mainContent').style.display = 'block';
    document.getElementById('header').style.display = 'block';
    
    updateUserIcon();
    updateMenuVisibility();
    showTab('home');
}

function updateUserIcon() {
    if (currentUser?.profile?.avatarUrl) {
        document.getElementById('userAvatar').src = currentUser.profile.avatarUrl;
        document.getElementById('userAvatar').style.display = 'block';
        document.getElementById('defaultAvatar').style.display = 'none';
    }
}

function updateMenuVisibility() {
    const isAdmin = currentUser?.roles?.some(role => role.name === '管理者');
    const isMember = currentUser?.roles?.some(role => role.name === 'メンバー');
    
    if (isAdmin) {
        document.getElementById('adminPanelBtn').style.display = 'block';
    }
    
    if (isMember) {
        document.getElementById('memberListBtn').style.display = 'block';
    }
}

// メニュー
function toggleMenu() {
    const menu = document.getElementById('menu');
    const overlay = document.getElementById('menuOverlay');
    
    if (menu.style.display === 'block') {
        menu.style.display = 'none';
        overlay.style.display = 'none';
    } else {
        menu.style.display = 'block';
        overlay.style.display = 'block';
    }
}

// タブ切り替え
function showTab(tabName) {
    // タブボタンの更新
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event?.target?.closest('.tab-btn')?.classList.add('active');
    
    // タブコンテンツの更新
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(`${tabName}Tab`).classList.add('active');
    
    // コンテンツの読み込み
    loadTabContent(tabName);
}

async function loadTabContent(tabName) {
    const container = document.getElementById(`${tabName}Tab`);
    
    switch(tabName) {
        case 'home':
            await loadHomeContent(container);
            break;
        case 'community':
            await loadCommunityContent(container);
            break;
        case 'event':
            await loadEventContent(container);
            break;
        case 'learning':
            await loadLearningContent(container);
            break;
        case 'shop':
            await loadShopContent(container);
            break;
        case 'setting':
            loadSettingContent(container);
            break;
    }
}

// Homeタブ
async function loadHomeContent(container) {
    try {
        const [milesData, eventsData, articlesData] = await Promise.all([
            apiCall('/miles/balance'),
            apiCall('/events'),
            apiCall('/learning')
        ]);
        
        container.innerHTML = `
            <h2>こんにちは、${currentUser.username}さん</h2>
            
            <div class="mile-card">
                <div class="card-subtitle">累計Mile</div>
                <div class="mile-amount">${milesData.miles} Mile</div>
            </div>
            
            <div class="card">
                <div class="card-title">新着情報</div>
                
                <h3>新しいイベント</h3>
                <div id="recentEvents"></div>
                
                <h3>新しい学習コンテンツ</h3>
                <div id="recentArticles"></div>
            </div>
        `;
        
        // 最新イベントを表示
        const recentEventsContainer = container.querySelector('#recentEvents');
        eventsData.events.slice(0, 3).forEach(event => {
            const eventEl = document.createElement('div');
            eventEl.className = 'list-item';
            eventEl.innerHTML = `
                <div>${event.title}</div>
                <div style="font-size: 12px; color: #8E8E93;">
                    ${new Date(event.date).toLocaleDateString('ja-JP')}
                </div>
            `;
            recentEventsContainer.appendChild(eventEl);
        });
        
        // 最新記事を表示
        const recentArticlesContainer = container.querySelector('#recentArticles');
        articlesData.articles.slice(0, 3).forEach(article => {
            const articleEl = document.createElement('div');
            articleEl.className = 'list-item';
            articleEl.innerHTML = `
                <div>${article.title}</div>
                <div style="font-size: 12px; color: #8E8E93;">
                    ${article.category} • ${article.milesReward} Mile
                </div>
            `;
            recentArticlesContainer.appendChild(articleEl);
        });
    } catch (error) {
        container.innerHTML = '<div class="error-message" style="display: block;">データの読み込みに失敗しました</div>';
    }
}

// Communityタブ
async function loadCommunityContent(container) {
    try {
        const data = await apiCall('/channels');
        
        // カテゴリ別にチャンネルをグループ化
        const channelsByCategory = {};
        data.channels.forEach(channel => {
            const categoryName = channel.category.name;
            if (!channelsByCategory[categoryName]) {
                channelsByCategory[categoryName] = [];
            }
            channelsByCategory[categoryName].push(channel);
        });
        
        container.innerHTML = '<h2>Community</h2>';
        
        Object.entries(channelsByCategory).forEach(([categoryName, channels]) => {
            const accordionEl = document.createElement('div');
            accordionEl.className = 'accordion';
            accordionEl.innerHTML = `
                <div class="accordion-header" onclick="toggleAccordion(this)">
                    <span>${categoryName}</span>
                    <span>▼</span>
                </div>
                <div class="accordion-content">
                    ${channels.map(channel => `
                        <div class="list-item" onclick="openChannel('${channel._id}')">
                            # ${channel.name}
                        </div>
                    `).join('')}
                </div>
            `;
            container.appendChild(accordionEl);
        });
    } catch (error) {
        container.innerHTML = '<div class="error-message" style="display: block;">データの読み込みに失敗しました</div>';
    }
}

function toggleAccordion(header) {
    const content = header.nextElementSibling;
    content.classList.toggle('active');
}

async function openChannel(channelId) {
    alert('チャンネル詳細画面（実装予定）');
}

// Eventタブ
async function loadEventContent(container) {
    try {
        const data = await apiCall('/events');
        
        container.innerHTML = '<h2>Event</h2>';
        
        data.events.forEach(event => {
            const eventEl = document.createElement('div');
            eventEl.className = 'event-card';
            eventEl.innerHTML = `
                ${event.flyerImageUrl ? `<img src="${event.flyerImageUrl}" class="event-image" alt="${event.title}">` : ''}
                <div class="event-content">
                    <div class="event-title">${event.title}</div>
                    <div class="event-info">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M19 3h-1V1h-2v2H8V1H6v2H5c-1.11 0-1.99.9-1.99 2L3 19c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V8h14v11z"/>
                        </svg>
                        ${new Date(event.date).toLocaleDateString('ja-JP')}
                    </div>
                    <div class="event-info">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                        </svg>
                        ${event.venue}
                    </div>
                    <div class="event-info">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/>
                        </svg>
                        ${event.participants.length}人参加予定
                    </div>
                </div>
            `;
            container.appendChild(eventEl);
        });
    } catch (error) {
        container.innerHTML = '<div class="error-message" style="display: block;">データの読み込みに失敗しました</div>';
    }
}

// Learningタブ
async function loadLearningContent(container) {
    try {
        const data = await apiCall('/learning');
        
        container.innerHTML = `
            <h2>Learning</h2>
            <div id="learningArticles"></div>
        `;
        
        const articlesContainer = container.querySelector('#learningArticles');
        
        data.articles.forEach(article => {
            const articleEl = document.createElement('div');
            articleEl.className = 'card';
            articleEl.innerHTML = `
                <div class="card-title">${article.title}</div>
                ${article.subtitle ? `<div class="card-subtitle">${article.subtitle}</div>` : ''}
                <div style="margin-bottom: 10px;">
                    <span style="background: rgba(0, 122, 255, 0.2); padding: 4px 8px; border-radius: 4px; font-size: 12px;">
                        ${article.category}
                    </span>
                    <span style="margin-left: 10px;">⭐ ${article.milesReward} Mile</span>
                </div>
                ${article.isCompleted ? '<div style="color: #34C759;">✓ 完了済み</div>' : ''}
                <button class="btn btn-primary" onclick="window.open('${article.contentUrl}', '_blank')">
                    記事を読む
                </button>
            `;
            articlesContainer.appendChild(articleEl);
        });
    } catch (error) {
        container.innerHTML = '<div class="error-message" style="display: block;">データの読み込みに失敗しました</div>';
    }
}

// Shopタブ
async function loadShopContent(container) {
    try {
        const [milesData, itemsData] = await Promise.all([
            apiCall('/miles/balance'),
            apiCall('/shop')
        ]);
        
        container.innerHTML = `
            <h2>Shop</h2>
            
            <div class="card">
                <div class="card-subtitle">所持Mile</div>
                <div style="font-size: 32px; font-weight: bold;">⭐ ${milesData.miles} Mile</div>
            </div>
            
            <div class="card" style="background: rgba(0, 122, 255, 0.1);">
                <div class="card-title">Mile購入</div>
                <div class="card-subtitle">※今後実装予定</div>
                <p>1 Mile = 10円でMileを購入できます</p>
            </div>
            
            <h3>アイテム</h3>
            <div id="shopItems"></div>
        `;
        
        const itemsContainer = container.querySelector('#shopItems');
        
        if (itemsData.items.length === 0) {
            itemsContainer.innerHTML = '<p style="color: #8E8E93;">現在購入可能なアイテムはありません</p>';
        } else {
            itemsData.items.forEach(item => {
                const itemEl = document.createElement('div');
                itemEl.className = 'card';
                itemEl.innerHTML = `
                    <div class="card-title">${item.name}</div>
                    <div class="card-subtitle">${item.description}</div>
                    <div style="margin-bottom: 10px;">⭐ ${item.mileCost} Mile</div>
                    <button class="btn btn-primary" ${milesData.miles < item.mileCost ? 'disabled' : ''}>
                        購入する
                    </button>
                `;
                itemsContainer.appendChild(itemEl);
            });
        }
    } catch (error) {
        container.innerHTML = '<div class="error-message" style="display: block;">データの読み込みに失敗しました</div>';
    }
}

// Settingタブ
function loadSettingContent(container) {
    container.innerHTML = `
        <h2>Setting</h2>
        
        <div class="list">
            <div class="list-item">プッシュ通知設定</div>
        </div>
        
        <h3>サポート</h3>
        <div class="list">
            <div class="list-item" onclick="window.location.href='mailto:ecg_english@nauticalmile.jp'">
                お問い合わせ
            </div>
            <div class="list-item">よくある質問</div>
            <div class="list-item">利用規約</div>
            <div class="list-item">プライバシーポリシー</div>
        </div>
        
        <h3>アカウント</h3>
        <div class="list">
            <div class="list-item" style="color: #FF3B30;" onclick="logout()">ログアウト</div>
            <div class="list-item" style="color: #FF3B30;">アカウント削除</div>
        </div>
        
        <div class="card">
            <div class="card-subtitle">バージョン</div>
            <div>1.0.0</div>
        </div>
    `;
}

// メニュー機能
function showProfile() {
    toggleMenu();
    alert('プロフィール画面（実装予定）');
}

function showMemberList() {
    toggleMenu();
    alert('メンバーリスト画面（実装予定）');
}

function showAbout() {
    toggleMenu();
    alert('コミュニティ紹介画面（実装予定）');
}

function showEventCalendar() {
    toggleMenu();
    alert('イベントカレンダー画面（実装予定）');
}

function showAdminPanel() {
    toggleMenu();
    alert('管理者画面（実装予定）');
}

