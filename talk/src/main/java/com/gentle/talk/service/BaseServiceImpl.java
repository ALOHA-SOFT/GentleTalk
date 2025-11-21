package com.gentle.talk.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.gentle.talk.domain.Base;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class BaseServiceImpl<E extends Base, M extends BaseMapper<E>> extends ServiceImpl<M, E> implements BaseService<E> {

  @Autowired M mapper;

  @Override
  public List<E> list() {
    return mapper.selectList(null);
  }

  @Override
  public PageInfo<E> page(int page, int size) {
    PageHelper.startPage(page, size);
    QueryWrapper<E> queryWrapper = new QueryWrapper<>();
    queryWrapper.orderByDesc("no").orderByDesc("created_at");
    List<E> list = mapper.selectList(queryWrapper);
    return new PageInfo<>(list);
  }

  @Override
  public PageInfo<E> page(int page, int size, String search) {
    PageHelper.startPage(page, size);
    QueryWrapper<E> queryWrapper = new QueryWrapper<>();
    if (search != null && !search.isEmpty()) {
      // "name" 컬럼이 존재할 때만 조건 추가
      try {
        E entity = this.getEntityClass().getDeclaredConstructor().newInstance();
        boolean hasName = false;
        for (java.lang.reflect.Field field : entity.getClass().getDeclaredFields()) {
          if ("name".equals(field.getName())) {
        hasName = true;
        break;
          }
        }
        if (hasName) {
          queryWrapper.like("name", search).orderByDesc("no").orderByDesc("created_at");
        }
      } catch (Exception e) {
        e.printStackTrace();
        log.error("Error while checking for 'name' field in entity class: {}", e.getMessage());
      }
    }
    queryWrapper.orderByDesc("no").orderByDesc("created_at");
    List<E> list = mapper.selectList(queryWrapper);
    return new PageInfo<>(list);
  }

  @Override
  public E select(Long no) {
    return mapper.selectById(no);
  }

  @Override
  public E selectById(String id) {
    QueryWrapper<E> queryWrapper = new QueryWrapper<>();
    queryWrapper.eq("id", id);
    return mapper.selectOne(queryWrapper);
  }

  @Override
  public boolean insert(E entity) {
    return mapper.insert(entity) > 0;
  }

  @Override
  public boolean update(E entity) {
    QueryWrapper<E> queryWrapper = new QueryWrapper<>();
    queryWrapper.eq("no", entity.getNo());
    return mapper.update(entity, queryWrapper) > 0;
  }

  @Override
  public boolean updateById(E entity) {
    QueryWrapper<E> queryWrapper = new QueryWrapper<>();
    queryWrapper.eq("id", entity.getId());
    return mapper.update(entity, queryWrapper) > 0;
  }

  @Override
  public boolean delete(Long no) {
    QueryWrapper<E> queryWrapper = new QueryWrapper<>();
    queryWrapper.eq("no", no);
    return mapper.delete(queryWrapper) > 0;
  }

  @Override
  public boolean deleteById(String id) {
    QueryWrapper<E> queryWrapper = new QueryWrapper<>();
    queryWrapper.eq("id", id);
    return mapper.delete(queryWrapper) > 0;
  }

}
