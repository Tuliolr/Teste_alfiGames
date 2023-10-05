global.volume = 1;
global.currentVolume = 0;

sel = 0;
marg_val = 0;
marg_total = 32;
pag = 0;

#region Metodos
desenha_menu = function(_menu) {
	draw_set_font(fnt_menu);

	draw_set_valign(1);
	draw_set_halign(fa_center);

	var _qtd = array_length(_menu);
	var _alt = display_get_gui_height();
	var _larg = display_get_gui_width();
	var x1 = _alt / 2;
	var y1 = _larg / 2;

	var _espaco_y = string_height("I") + 16;
	var _alt_menu = _espaco_y * _qtd;

	var m_x = device_mouse_x_to_gui(0);
	var m_y = device_mouse_y_to_gui(0);



for (var i = 0; i < _qtd; i++)
{
	var _cor = c_white, _marg_x = 0;
	var _texto = _menu[i][0];
	
	var y2 = y1 + (50 * i);
	var string_w = string_width(menus_sel[pag]);
	var string_h = string_height(menus_sel[pag]);
	
	if(point_in_rectangle(m_x, m_y,x1 - string_w / 2,y2 - string_h/ 2, x1 + string_w / 2,y2 + string_h / 2))
	{
		draw_set_color(c_red);
	} else {
		draw_set_color(c_white);
	}
	if(menus_sel[pag] == i) {
	  _cor = c_red;
	  _marg_x = marg_val;
	}
	
	draw_text_color(y1 + _marg_x, (_alt / 2) - _alt_menu / 2 + (i * _espaco_y), _texto, _cor,_cor,_cor,_cor, 1);
} 

for (var i = 0; i < _qtd; i++)
{
	switch(_menu[i][1])
	{
		case menu_acoes.ajustes_menu:
		{
			var _indice = _menu[i][3];
			var _txt = _menu[i][4][_indice];
			
			var _esq = _indice > 0 ? "<< " : "";
			var _dir = _indice < array_length(_menu[i][4]) - 1 ? " >>" : "";
			
			var _cor = c_white;
			var margin = 200;
			
			if (alterando && menus_sel[pag] == i) _cor = c_red;
			
			draw_text_color((_larg / 2) + margin, (_alt / 2) - _alt_menu / 2 + (i * _espaco_y), _esq + _txt + _dir, _cor, _cor, _cor, _cor, 1);
			break;
		}
	}
}

	draw_set_font(-1);
	draw_set_valign(-1);   
	draw_set_halign(-1);
}

controla_menu = function(_menu) {
	var _up, _down, _avanca, _recua, _left, _right;
	
	var _sel = menus_sel[pag];

	_up = keyboard_check_pressed(vk_up);
	_down = keyboard_check_pressed(vk_down);
	_avanca = keyboard_check_pressed(vk_enter);
	_recua = keyboard_check_pressed(vk_escape);
	_left = keyboard_check_pressed(vk_left);
	_right = keyboard_check_pressed(vk_right);


	if (!alterando) {

		if (_up or _down)
		{
			menus_sel[pag] += _down - _up;
	
			var _tam = array_length(_menu) - 1;
			menus_sel[pag] = clamp(menus_sel[pag], 0, _tam);
			marg_val = 0;
		
			}
	}
	
	else {
		
		if (_right or _left)
		{
			var _limite = array_length(_menu[_sel][4]) - 1;
			menus[pag][_sel][3] += _right - _left;
			menus[pag][_sel][3] = clamp(menus[pag][_sel][3], 0, _limite);
		}
	}
	
	if(_avanca)
	{
		switch(_menu[_sel][1])
		{
			case menu_acoes.roda_metodo: _menu[_sel][2](); break;
			case menu_acoes.carregar_menu: pag = _menu[_sel][2]; break;
			case menu_acoes.ajustes_menu: 
				alterando = !alterando;
			
			if(!alterando)
			{
				var _arg = _menu[_sel][3];
				_menu[_sel][2](_arg);
			}
			break;
		}
	}
	
	marg_val = lerp(marg_val, marg_total, .1);
}

inicia_jogo = function()
{
	room_goto(rm_gameplay);
}

fecha_jogo = function()
{
	if(show_question("Você deseja sair?")){
	game_end();
	}
}

volume = function() 
{
	if (global.currentVolume != global.volume) {
	global.currentVolume = global.volume;
	var num = audio_get_listener_count();
	for (var i = 0; i < num; ++i;)
	{
		var info = audio_get_listener_info(i);
		var ind = info[? "index"];
		audio_set_master_gain(info[? "index"], global.currentVolume/10);
		ds_map_destroy(info);
	}
  }
}

ajusta_tela = function(_valor)
{
	switch(_valor)
	{
		case 0: window_set_fullscreen(true); break;
		
		case 1: window_set_fullscreen(false); break;
	}
}
#endregion
menu_principal = [
					["Jogar", menu_acoes.roda_metodo, inicia_jogo],
					["Configurações", menu_acoes.carregar_menu, menus_lista.opcoes],
					["Sair", menu_acoes.roda_metodo, fecha_jogo]
				 ];	

menu_opcoes = [
					["Volume", menu_acoes.carregar_menu,menus_lista.volume, inicia_jogo],
					["Tela Cheia", menu_acoes.carregar_menu, menus_lista.tela],
					["Voltar", menu_acoes.carregar_menu, menus_lista.principal]
				
			  ];
				
menu_tela = [		// selecionar o menu com Enter
					["Tipo de tela", menu_acoes.ajustes_menu, ajusta_tela, 1, ["Tela cheia", "Janela"]],
					["Voltar", menu_acoes.carregar_menu, menus_lista.opcoes]
			];
			
menu_volume = [		// selecionar o menu com Enter
					["Ajuster", menu_acoes.ajustes_menu, volume, 1, ["key_up", "key_down"]],
					["Voltar", menu_acoes.carregar_menu, menus_lista.opcoes]
			  ];			
				

menus = [menu_principal, menu_opcoes, menu_tela, menu_volume];

menus_sel = array_create(array_length(menus), 0);

alterando = false;