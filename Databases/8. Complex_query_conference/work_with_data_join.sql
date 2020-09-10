-- Запросы на БД Vk
USE vk;

-- Выборка данных по пользователю
SELECT first_name, last_name, email, gender, birthday, city
  FROM users
    INNER JOIN profiles
      ON users.id = profiles.user_id
  WHERE users.id = 7;

-- Выборка медиафайлов пользователя
SELECT media.id, users.first_name, users.last_name, media.user_id, media.filepath, media.created_at
  FROM media
    JOIN users
      ON media.user_id = users.id     
  WHERE media.user_id = 7;
  
-- Выборка фотографий пользователя
SELECT media.id, users.first_name, users.last_name, media.user_id, media.filepath, media.created_at
  FROM media
    JOIN users
      ON media.user_id = users.id
    JOIN media_types
      ON media.media_type_id = media_types.id     
  WHERE media.user_id = 8 AND media_types.name = 'photo';


-- Выборка медиафайлов друзей пользователя
-- Вариант 1
SELECT DISTINCT media.id, media.user_id, media.filepath, media.created_at
  FROM media
    JOIN friendship
      ON media.user_id = friendship.user_id
        OR media.user_id = friendship.friend_id
    JOIN users 
      ON users.id = friendship.friend_id
        OR users.id = friendship.user_id   
  WHERE users.id = 7;

-- Вариант 2
SELECT DISTINCT media.id, media.user_id, media.filepath, media.created_at
  FROM media
    JOIN friendship
    JOIN users 
      ON (users.id = friendship.friend_id 
        OR users.id = friendship.user_id)
      AND (media.user_id = friendship.user_id 
        OR media.user_id = friendship.friend_id)   
  WHERE users.id = 7;


-- Отберём только медиафайлы друзей  
SELECT DISTINCT media.user_id, media.filepath, media.created_at
  FROM media
    JOIN friendship
    JOIN users 
      ON (users.id = friendship.friend_id 
        OR users.id = friendship.user_id)
      AND (media.user_id = friendship.user_id 
        OR media.user_id = friendship.friend_id)   
  WHERE users.id = 7 AND media.user_id != 7;

-- Проверка
SELECT user_id, friend_id FROM friendship WHERE user_id = 7 OR friend_id = 7;


-- Выборка фотографий пользователя и друзей пользователя (без DISTINCT)
SELECT media.id, media.user_id, media.filepath, media.created_at
  FROM media
    JOIN friendship
      ON media.user_id = friendship.user_id
        OR media.user_id = friendship.friend_id
    JOIN media_types
      ON media.media_type_id = media_types.id
    JOIN users 
      ON users.id = friendship.friend_id
        OR users.id = friendship.user_id   
  WHERE users.id = 7 AND media_types.name = 'photo';
  
-- Используем DISTINC  
SELECT DISTINCT media.id, media.user_id, media.filepath, media.created_at
  FROM media
    JOIN friendship
      ON media.user_id = friendship.user_id
        OR media.user_id = friendship.friend_id
    JOIN media_types
      ON media.media_type_id = media_types.id
    JOIN users 
      ON users.id = friendship.friend_id
        OR users.id = friendship.user_id   
  WHERE users.id = 7 AND media_types.name = 'photo';  


-- Сообщения от пользователя
SELECT messages.body, users.first_name, users.last_name, messages.created_at
  FROM messages
    JOIN users
      ON users.id = messages.to_user_id
  WHERE messages.from_user_id = 7;

-- Сообщения к пользователю
SELECT body, first_name, last_name, messages.created_at
  FROM messages
    JOIN users
      ON users.id = messages.from_user_id
  WHERE messages.to_user_id = 7;
  
-- Объединяем все сообщения от пользователя и к пользователю
SELECT messages.from_user_id, messages.to_user_id, messages.body, messages.created_at
  FROM users
    JOIN messages
      ON users.id = messages.to_user_id
        OR users.id = messages.from_user_id
  WHERE users.id = 7;


-- Количество друзей у пользователей с сортировкой
-- Выполним объединение и посмотрим на результат
SELECT users.id, first_name, last_name, friendship.created_at
  FROM users
    LEFT JOIN friendship
      ON users.id = friendship.user_id
        OR users.id = friendship.friend_id
        ORDER BY users.id;

-- Затем подсчитаем
SELECT users.id, first_name, last_name, COUNT(friendship.created_at) AS total_friends
  FROM users
    LEFT JOIN friendship
      ON users.id = friendship.user_id
        OR users.id = friendship.friend_id
  GROUP BY users.id
  ORDER BY total_friends DESC
  LIMIT 10;


-- Список медиафайлов пользователя с количеством лайков
SELECT likes.target_id,
  media.filepath,
  target_types.name AS target_type,
  COUNT(DISTINCT(likes.id)) AS total_likes,
  CONCAT(first_name, ' ', last_name) AS owner
  FROM media
    LEFT JOIN likes
      ON media.id = likes.target_id
    LEFT JOIN target_types
      ON likes.target_type_id = target_types.id
    LEFT JOIN users
      ON users.id = media.user_id
  WHERE users.id = 7 AND target_types.name = 'media'
  GROUP BY media.id;

-- 10 пользователей с наибольшим количеством лайков за медиафайлы
SELECT users.id, first_name, last_name, COUNT(target_types.id) AS total_likes
  FROM users
    LEFT JOIN media
      ON users.id = media.user_id
    LEFT JOIN likes
      ON media.id = likes.target_id
    LEFT JOIN target_types
      ON likes.target_type_id = target_types.id
        AND target_types.name = 'media'
  GROUP BY users.id
  ORDER BY total_likes DESC
  LIMIT 10;